class_name Enemy
extends CharacterBody2D

signal died(enemy)

@export var speed: float = 100.0
@export var max_health: int = 30
@export var attack_damage: int = 15
@export var detection_range: float = 150.0
@export var attack_range: float = 40.0
@export var xp_value: int = 25

var current_health: int
var player: Player = null
var is_attacking: bool = false
var is_dead: bool = false
var last_direction: Vector2 = Vector2.DOWN

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_area: Area2D = $AttackArea
@onready var attack_collision: CollisionShape2D = $AttackArea/CollisionShape2D
@onready var detection_area: Area2D = $DetectionArea
@onready var attack_timer: Timer = $AttackTimer
@onready var health_bar: ProgressBar = $HealthBar

# AI states
enum AIState {
	IDLE,
	PATROL,
	CHASE,
	ATTACK,
	DEAD
}

var current_state: AIState = AIState.IDLE
var patrol_target: Vector2
var patrol_timer: float = 0.0
var attack_cooldown: float = 0.0

func _ready():
	current_health = max_health
	
	# Connect signals
	detection_area.body_entered.connect(_on_detection_area_body_entered)
	detection_area.body_exited.connect(_on_detection_area_body_exited)
	attack_area.body_entered.connect(_on_attack_area_body_entered)
	attack_timer.timeout.connect(_on_attack_timeout)
	
	# Setup detection area
	var detection_shape = CircleShape2D.new()
	detection_shape.radius = detection_range
	detection_area.get_child(0).shape = detection_shape
	
	# Setup health bar
	health_bar.max_value = max_health
	health_bar.value = current_health
	
	# Disable attack area initially
	attack_collision.disabled = true
	
	# Set initial patrol target
	set_new_patrol_target()

func _physics_process(delta):
	if is_dead:
		return
	
	update_attack_cooldown(delta)
	
	match current_state:
		AIState.IDLE:
			handle_idle_state(delta)
		AIState.PATROL:
			handle_patrol_state(delta)
		AIState.CHASE:
			handle_chase_state(delta)
		AIState.ATTACK:
			handle_attack_state(delta)
	
	move_and_slide()

func update_attack_cooldown(delta):
	if attack_cooldown > 0:
		attack_cooldown -= delta

func handle_idle_state(delta):
	velocity = Vector2.ZERO
	patrol_timer += delta
	
	if patrol_timer >= 2.0:  # Wait 2 seconds before patrolling
		current_state = AIState.PATROL
		set_new_patrol_target()
	
	play_animation("idle")

func handle_patrol_state(delta):
	var direction = (patrol_target - global_position).normalized()
	velocity = direction * speed * 0.5  # Slower patrol speed
	
	# Check if reached patrol target
	if global_position.distance_to(patrol_target) < 20.0:
		current_state = AIState.IDLE
		patrol_timer = 0.0
	
	last_direction = direction
	play_animation("walk")

func handle_chase_state(delta):
	if not player:
		current_state = AIState.IDLE
		return
	
	var distance_to_player = global_position.distance_to(player.global_position)
	
	if distance_to_player > detection_range * 1.2:  # Lost player
		current_state = AIState.IDLE
		player = null
		return
	
	if distance_to_player <= attack_range and attack_cooldown <= 0:
		current_state = AIState.ATTACK
		return
	
	# Move towards player
	var direction = (player.global_position - global_position).normalized()
	velocity = direction * speed
	last_direction = direction
	play_animation("walk")

func handle_attack_state(delta):
	if not player:
		current_state = AIState.IDLE
		return
	
	velocity = Vector2.ZERO
	
	if not is_attacking and attack_cooldown <= 0:
		attack()

func set_new_patrol_target():
	# Set random patrol target within a reasonable range
	var angle = randf() * 2 * PI
	var distance = randf_range(50, 100)
	patrol_target = global_position + Vector2(cos(angle), sin(angle)) * distance

func play_animation(anim_name: String):
	if sprite.animation != anim_name:
		sprite.play(anim_name)
	
	# Flip sprite based on direction
	if last_direction.x < 0:
		sprite.flip_h = true
	elif last_direction.x > 0:
		sprite.flip_h = false

func attack():
	is_attacking = true
	attack_cooldown = 2.0  # 2 second cooldown between attacks
	play_animation("attack")
	
	# Enable attack collision
	attack_collision.disabled = false
	attack_timer.start(0.5)  # Attack duration

func _on_attack_area_body_entered(body):
	if body == player and is_attacking:
		player.take_damage(attack_damage)

func _on_attack_timeout():
	is_attacking = false
	attack_collision.disabled = true
	current_state = AIState.CHASE

func _on_detection_area_body_entered(body):
	if body is Player:
		player = body
		current_state = AIState.CHASE

func _on_detection_area_body_exited(body):
	if body == player:
		# Don't immediately lose player, give some grace period
		pass

func take_damage(damage: int):
	if is_dead:
		return
	
	current_health -= damage
	current_health = max(0, current_health)
	
	# Update health bar
	health_bar.value = current_health
	
	# Flash effect
	var tween = create_tween()
	tween.tween_method(_flash_sprite, 0.0, 1.0, 0.3)
	
	if current_health <= 0:
		die()

func _flash_sprite(value: float):
	sprite.modulate = Color.RED.lerp(Color.WHITE, value)

func die():
	if is_dead:
		return
	
	is_dead = true
	current_state = AIState.DEAD
	
	# Play death animation
	play_animation("death")
	
	# Disable collision
	set_collision_layer_value(2, false)  # Enemy layer
	set_collision_mask_value(1, false)   # Player layer
	
	# Drop loot
	drop_loot()
	
	# Give XP to player
	if player:
		player.gain_xp(xp_value)
	
	# Remove after animation
	await sprite.animation_finished
	died.emit(self)
	queue_free()

func drop_loot():
	var drop_chance = randf()
	
	if drop_chance < 0.3:  # 30% chance for health potion
		drop_item("res://scenes/HealthPotion.tscn")
	elif drop_chance < 0.1:  # 10% chance for weapon
		drop_item("res://scenes/Weapon.tscn")
	elif drop_chance < 0.05:  # 5% chance for armor
		drop_item("res://scenes/Armor.tscn")

func drop_item(item_scene_path: String):
	var item_scene = load(item_scene_path)
	var item = item_scene.instantiate()
	get_parent().add_child(item)
	item.global_position = global_position + Vector2(randf_range(-20, 20), randf_range(-20, 20))

func setup_for_floor(floor_level: int):
	# Scale enemy stats based on floor level
	var scale_factor = 1.0 + (floor_level - 1) * 0.3
	
	max_health = int(max_health * scale_factor)
	current_health = max_health
	attack_damage = int(attack_damage * scale_factor)
	xp_value = int(xp_value * scale_factor)
	
	# Update health bar
	health_bar.max_value = max_health
	health_bar.value = current_health
	
	# Change sprite tint based on floor level
	var tint_intensity = min(floor_level * 0.1, 0.5)
	sprite.modulate = Color.WHITE.lerp(Color.RED, tint_intensity)
