class_name MagicProjectile
extends CharacterBody2D

@export var speed: float = 400.0
@export var damage: int = 15
@export var lifetime: float = 3.0

var direction: Vector2 = Vector2.RIGHT

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var area: Area2D = $Area2D
@onready var lifetime_timer: Timer = $LifetimeTimer

func _ready():
	# Connect signals
	area.body_entered.connect(_on_area_body_entered)
	lifetime_timer.timeout.connect(_on_lifetime_timeout)
	
	# Start lifetime timer
	lifetime_timer.wait_time = lifetime
	lifetime_timer.start()
	
	# Play animation
	sprite.play("default")

func _physics_process(delta):
	velocity = direction * speed
	move_and_slide()

func _on_area_body_entered(body):
	if body.has_method("take_damage") and body != get_parent().get_node("Player"):
		body.take_damage(damage)
		destroy_projectile()

func _on_lifetime_timeout():
	destroy_projectile()

func destroy_projectile():
	# Add particle effect here if needed
	queue_free()
