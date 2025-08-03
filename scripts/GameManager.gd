extends Node

# Game Manager - Handles scene transitions, saving/loading, and global game state

var current_floor: int = 1
var player_data: Dictionary = {}
var game_scene: PackedScene = preload("res://scenes/Dungeon.tscn")

const SAVE_FILE_PATH = "user://savegame.dat"

func _ready():
	# Set up process mode to continue during pause
	process_mode = Node.PROCESS_MODE_ALWAYS

func start_new_game():
	current_floor = 1
	player_data.clear()
	load_dungeon_scene()

func load_game():
	if has_save_file():
		var save_data = load_save_file()
		if save_data:
			current_floor = save_data.get("current_floor", 1)
			player_data = save_data.get("player_data", {})
			load_dungeon_scene()
	else:
		print("No save file found")

func load_dungeon_scene():
	var dungeon_scene = game_scene.instantiate()
	get_tree().root.add_child(dungeon_scene)
	get_tree().current_scene.queue_free()
	get_tree().current_scene = dungeon_scene
	
	# Setup the dungeon for current floor
	if dungeon_scene.has_method("setup_floor"):
		dungeon_scene.setup_floor(current_floor, player_data)

func next_floor():
	current_floor += 1
	save_game()
	load_dungeon_scene()

func return_to_main_menu():
	var main_menu_scene = preload("res://scenes/MainMenu.tscn").instantiate()
	get_tree().root.add_child(main_menu_scene)
	get_tree().current_scene.queue_free()
	get_tree().current_scene = main_menu_scene

func save_game():
	var save_data = {
		"current_floor": current_floor,
		"player_data": player_data,
		"timestamp": Time.get_unix_time_from_system()
	}
	
	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
	if file:
		file.store_var(save_data)
		file.close()
		print("Game saved successfully")
	else:
		print("Failed to save game")

func load_save_file() -> Dictionary:
	if FileAccess.file_exists(SAVE_FILE_PATH):
		var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
		if file:
			var save_data = file.get_var()
			file.close()
			return save_data
	
	return {}

func has_save_file() -> bool:
	return FileAccess.file_exists(SAVE_FILE_PATH)

func delete_save_file():
	if has_save_file():
		DirAccess.remove_absolute(SAVE_FILE_PATH)

func update_player_data(new_player_data: Dictionary):
	player_data = new_player_data

func get_current_floor() -> int:
	return current_floor

func quit_game():
	save_game()
	get_tree().quit()
