class_name Player
extends CharacterBody2D

signal health_changed(new_health, max_health)
signal xp_changed(new_xp, xp_to_next_level)
signal level_up(new_level)
signal died

@export var speed: float = 200.0
@export var attack_damage: int = 10
@export var attack_range: float = 50.0

var max_health: int = 100
var current_health: int = 100
var level: int = 1
var current_xp: int = 0
var xp_to_next_level: int = 100
var attack_power: int = 10
var defense: int = 5

var is_attacking: bool = false
var is_invincible: bool = false
var last_direction: Vector2 = Vector2.DOWN

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_area: Area2D = $AttackArea
@onready var attack_collision: CollisionShape2D = $AttackArea/CollisionShape2D
@onready var invincibility_timer: Timer = $InvincibilityTimer
@onready var attack_timer: Timer = $AttackTimer

# Inventory and equipment
var inventory: Array[Item] = []
var equipped_weapon: Weapon = null
var equipped_armor: Armor = null

func _ready():
	# Connect signals
	attack_area.body_entered.connect(_on_attack_area_body_entered)
	invincibility_timer.timeout.connect(_on_invincibility_timeout)
	attack_timer.timeout.connect(_on_attack_timeout)
	
	# Initialize UI
	health_changed.emit(current_health, max_health)
	xp_changed.emit(current_xp, xp_to_next_level)
	
	# Disable attack area initially
	attack_collision.disabled = true

func _physics_process(delta):
	if is_attacking:
		return
		
	handle_movement()
	handle_input()

func handle_movement():
	var input_direction = Vector2.ZERO
	
	if Input.is_action_pressed("move_up"):
		input_direction.y -= 1
	if Input.is_action_pressed("move_down"):
		input_direction.y += 1
	if Input.is_action_pressed("move_left"):
		input_direction.x -= 1
	if Input.is_action_pressed("move_right"):
		input_direction.x += 1
	
	# Normalize diagonal movement
	if input_direction.length() > 0:
		input_direction = input_direction.normalized()
		last_direction = input_direction
		velocity = input_direction * speed
		play_animation("walk")
	else:
		velocity = Vector2.ZERO
		play_animation("idle")
	
	move_and_slide()

func handle_input():
	if Input.is_action_just_pressed("attack") and not is_attacking:
		attack()
	
	if Input.is_action_just_pressed("magic") and not is_attacking:
		cast_magic()

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
	play_animation("attack")
	
	# Position attack area based on direction
	var attack_position = last_direction * attack_range
	attack_area.position = attack_position
	
	# Enable attack collision
	attack_collision.disabled = false
	attack_timer.start(0.3)  # Attack duration

func cast_magic():
	# Create magic projectile
	var projectile_scene = preload("res://scenes/MagicProjectile.tscn")
	var projectile = projectile_scene.instantiate()
	get_parent().add_child(projectile)
	projectile.global_position = global_position
	projectile.direction = last_direction
	projectile.damage = attack_power / 2

func _on_attack_area_body_entered(body):
	if body.has_method("take_damage") and body != self:
		var damage = calculate_damage()
		body.take_damage(damage)

func _on_attack_timeout():
	is_attacking = false
	attack_collision.disabled = true
	play_animation("idle")

func calculate_damage() -> int:
	var base_damage = attack_power
	if equipped_weapon:
		base_damage += equipped_weapon.damage
	return base_damage

func take_damage(damage: int):
	if is_invincible:
		return
	
	var actual_damage = max(1, damage - defense)
	if equipped_armor:
		actual_damage = max(1, actual_damage - equipped_armor.defense)
	
	current_health -= actual_damage
	current_health = max(0, current_health)
	
	health_changed.emit(current_health, max_health)
	
	if current_health <= 0:
		die()
	else:
		# Start invincibility frames
		is_invincible = true
		invincibility_timer.start(1.0)
		# Flash effect
		var tween = create_tween()
		tween.tween_method(_flash_sprite, 0.0, 1.0, 1.0)

func _flash_sprite(value: float):
	sprite.modulate.a = 0.5 + 0.5 * sin(value * 20)

func _on_invincibility_timeout():
	is_invincible = false
	sprite.modulate.a = 1.0

func die():
	died.emit()
	# Play death animation and disable player
	play_animation("death")
	set_physics_process(false)

func gain_xp(amount: int):
	current_xp += amount
	xp_changed.emit(current_xp, xp_to_next_level)
	
	if current_xp >= xp_to_next_level:
		level_up()

func level_up():
	level += 1
	current_xp -= xp_to_next_level
	xp_to_next_level = int(xp_to_next_level * 1.2)  # Increase XP requirement
	
	# Increase stats
	max_health += 20
	current_health = max_health
	attack_power += 5
	defense += 2
	
	level_up.emit(level)
	health_changed.emit(current_health, max_health)
	xp_changed.emit(current_xp, xp_to_next_level)

func add_item_to_inventory(item: Item):
	inventory.append(item)

func equip_weapon(weapon: Weapon):
	if equipped_weapon:
		add_item_to_inventory(equipped_weapon)
	equipped_weapon = weapon

func equip_armor(armor: Armor):
	if equipped_armor:
		add_item_to_inventory(equipped_armor)
	equipped_armor = armor

func heal(amount: int):
	current_health = min(max_health, current_health + amount)
	health_changed.emit(current_health, max_health)

func save_data() -> Dictionary:
	return {
		"level": level,
		"current_health": current_health,
		"max_health": max_health,
		"current_xp": current_xp,
		"xp_to_next_level": xp_to_next_level,
		"attack_power": attack_power,
		"defense": defense,
		"position": {"x": global_position.x, "y": global_position.y}
	}

func load_data(data: Dictionary):
	level = data.get("level", 1)
	current_health = data.get("current_health", 100)
	max_health = data.get("max_health", 100)
	current_xp = data.get("current_xp", 0)
	xp_to_next_level = data.get("xp_to_next_level", 100)
	attack_power = data.get("attack_power", 10)
	defense = data.get("defense", 5)
	
	if data.has("position"):
		global_position = Vector2(data.position.x, data.position.y)
	
	health_changed.emit(current_health, max_health)
	xp_changed.emit(current_xp, xp_to_next_level)
