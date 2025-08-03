class_name DungeonScene
extends Node2D

@onready var dungeon_generator: DungeonGenerator = $DungeonGenerator
@onready var player: Player = $Player
@onready var camera: Camera2D = $Player/Camera2D
@onready var ui: GameUI = $UI
@onready var enemies_container: Node2D = $Enemies

var current_floor: int = 1
var enemies: Array[Enemy] = []

func _ready():
	# Connect signals
	dungeon_generator.dungeon_generated.connect(_on_dungeon_generated)
	player.died.connect(_on_player_died)
	
	# Setup UI
	ui.setup_player(player)
	
	# Generate first dungeon
	generate_dungeon()

func setup_floor(floor_level: int, player_data: Dictionary = {}):
	current_floor = floor_level
	
	# Load player data if available
	if not player_data.is_empty():
		player.load_data(player_data)
	
	generate_dungeon()

func generate_dungeon():
	dungeon_generator.generate_dungeon(current_floor)

func _on_dungeon_generated():
	# Position player at spawn point
	player.global_position = dungeon_generator.get_player_spawn_position()
	
	# Update camera limits based on dungeon size
	setup_camera_limits()

func setup_camera_limits():
	var tilemap = dungeon_generator.get_node("TileMap")
	var used_rect = tilemap.get_used_rect()
	var tile_size = tilemap.tile_set.tile_size
	
	camera.limit_left = used_rect.position.x * tile_size.x
	camera.limit_top = used_rect.position.y * tile_size.y
	camera.limit_right = (used_rect.position.x + used_rect.size.x) * tile_size.x
	camera.limit_bottom = (used_rect.position.y + used_rect.size.y) * tile_size.y

func _on_player_died():
	# Show game over screen
	ui.show_game_over_screen()

func _on_exit_door_entered():
	# Player reached exit, go to next floor
	GameManager.update_player_data(player.save_data())
	GameManager.next_floor()

func add_enemy(enemy: Enemy):
	enemies_container.add_child(enemy)
	enemies.append(enemy)
	enemy.died.connect(_on_enemy_died)

func _on_enemy_died(enemy: Enemy):
	enemies.erase(enemy)
