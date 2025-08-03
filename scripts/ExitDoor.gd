class_name ExitDoor
extends Area2D

signal player_entered

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready():
	body_entered.connect(_on_body_entered)
	sprite.play("default")

func _on_body_entered(body):
	if body is Player:
		player_entered.emit()
		# Connect to dungeon scene if available
		var dungeon_scene = get_parent()
		if dungeon_scene.has_method("_on_exit_door_entered"):
			dungeon_scene._on_exit_door_entered()
