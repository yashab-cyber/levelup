class_name DungeonGenerator
extends Node2D

signal dungeon_generated

@export var dungeon_width: int = 50
@export var dungeon_height: int = 50
@export var room_min_size: int = 6
@export var room_max_size: int = 12
@export var max_rooms: int = 15

var tilemap: TileMap
var rooms: Array[Rect2i] = []
var floor_tiles: Array[Vector2i] = []

enum TileType {
	WALL = 0,
	FLOOR = 1,
	DOOR = 2
}

func _ready():
	tilemap = get_node("TileMap")

func generate_dungeon(floor_level: int = 1):
	clear_dungeon()
	rooms.clear()
	floor_tiles.clear()
	
	# Generate rooms
	for i in range(max_rooms):
		var room = create_random_room()
		if can_place_room(room):
			rooms.append(room)
			create_room(room)
	
	# Connect rooms with corridors
	connect_rooms()
	
	# Add walls around floors
	add_walls()
	
	# Spawn enemies and items
	spawn_entities(floor_level)
	
	# Place exit door
	place_exit_door()
	
	dungeon_generated.emit()

func clear_dungeon():
	if tilemap:
		tilemap.clear()

func create_random_room() -> Rect2i:
	var room_width = randi_range(room_min_size, room_max_size)
	var room_height = randi_range(room_min_size, room_max_size)
	var x = randi_range(1, dungeon_width - room_width - 1)
	var y = randi_range(1, dungeon_height - room_height - 1)
	
	return Rect2i(x, y, room_width, room_height)

func can_place_room(new_room: Rect2i) -> bool:
	# Expand room bounds for collision check
	var expanded_room = Rect2i(
		new_room.position.x - 1,
		new_room.position.y - 1,
		new_room.size.x + 2,
		new_room.size.y + 2
	)
	
	for room in rooms:
		if expanded_room.intersects(room):
			return false
	
	return true

func create_room(room: Rect2i):
	for x in range(room.position.x, room.position.x + room.size.x):
		for y in range(room.position.y, room.position.y + room.size.y):
			var pos = Vector2i(x, y)
			tilemap.set_cell(0, pos, 0, Vector2i(TileType.FLOOR, 0))
			floor_tiles.append(pos)

func connect_rooms():
	for i in range(1, rooms.size()):
		var prev_room = rooms[i - 1]
		var current_room = rooms[i]
		
		var prev_center = prev_room.get_center()
		var current_center = current_room.get_center()
		
		create_corridor(prev_center, current_center)

func create_corridor(start: Vector2i, end: Vector2i):
	var current = start
	
	# Create L-shaped corridor
	# First horizontal
	while current.x != end.x:
		if current.x < end.x:
			current.x += 1
		else:
			current.x -= 1
		
		if tilemap.get_cell_source_id(0, current) == -1:
			tilemap.set_cell(0, current, 0, Vector2i(TileType.FLOOR, 0))
			floor_tiles.append(current)
	
	# Then vertical
	while current.y != end.y:
		if current.y < end.y:
			current.y += 1
		else:
			current.y -= 1
		
		if tilemap.get_cell_source_id(0, current) == -1:
			tilemap.set_cell(0, current, 0, Vector2i(TileType.FLOOR, 0))
			floor_tiles.append(current)

func add_walls():
	var walls_to_add: Array[Vector2i] = []
	
	for tile_pos in floor_tiles:
		# Check all 8 directions around floor tiles
		for x_offset in range(-1, 2):
			for y_offset in range(-1, 2):
				if x_offset == 0 and y_offset == 0:
					continue
				
				var wall_pos = tile_pos + Vector2i(x_offset, y_offset)
				
				# If position is empty, place a wall
				if tilemap.get_cell_source_id(0, wall_pos) == -1:
					walls_to_add.append(wall_pos)
	
	# Remove duplicates and place walls
	var unique_walls = {}
	for wall_pos in walls_to_add:
		unique_walls[wall_pos] = true
	
	for wall_pos in unique_walls.keys():
		tilemap.set_cell(0, wall_pos, 0, Vector2i(TileType.WALL, 0))

func spawn_entities(floor_level: int):
	var enemy_scene = preload("res://scenes/Enemy.tscn")
	var item_scenes = [
		preload("res://scenes/HealthPotion.tscn"),
		preload("res://scenes/Weapon.tscn"),
		preload("res://scenes/Armor.tscn")
	]
	
	# Spawn enemies (more enemies on higher floors)
	var enemy_count = min(rooms.size() * 2, 5 + floor_level)
	for i in range(enemy_count):
		spawn_enemy_in_random_room(enemy_scene, floor_level)
	
	# Spawn items
	var item_count = randi_range(3, 6)
	for i in range(item_count):
		spawn_item_in_random_room(item_scenes[randi() % item_scenes.size()])

func spawn_enemy_in_random_room(enemy_scene: PackedScene, floor_level: int):
	if rooms.is_empty():
		return
	
	var room = rooms[randi() % rooms.size()]
	var spawn_pos = get_random_floor_position_in_room(room)
	
	if spawn_pos != Vector2i(-1, -1):
		var enemy = enemy_scene.instantiate()
		get_parent().add_child(enemy)
		enemy.global_position = tilemap.map_to_local(spawn_pos)
		enemy.setup_for_floor(floor_level)

func spawn_item_in_random_room(item_scene: PackedScene):
	if rooms.is_empty():
		return
	
	var room = rooms[randi() % rooms.size()]
	var spawn_pos = get_random_floor_position_in_room(room)
	
	if spawn_pos != Vector2i(-1, -1):
		var item = item_scene.instantiate()
		get_parent().add_child(item)
		item.global_position = tilemap.map_to_local(spawn_pos)

func get_random_floor_position_in_room(room: Rect2i) -> Vector2i:
	# Try to find a valid floor position in the room
	for attempt in range(50):  # Max attempts to avoid infinite loop
		var x = randi_range(room.position.x + 1, room.position.x + room.size.x - 2)
		var y = randi_range(room.position.y + 1, room.position.y + room.size.y - 2)
		var pos = Vector2i(x, y)
		
		if tilemap.get_cell_atlas_coords(0, pos) == Vector2i(TileType.FLOOR, 0):
			return pos
	
	return Vector2i(-1, -1)  # Failed to find position

func place_exit_door():
	if rooms.is_empty():
		return
	
	# Place exit in the last room
	var last_room = rooms[-1]
	var door_pos = Vector2i(
		last_room.position.x + last_room.size.x / 2,
		last_room.position.y + last_room.size.y / 2
	)
	
	tilemap.set_cell(0, door_pos, 0, Vector2i(TileType.DOOR, 0))
	
	# Create exit door node
	var exit_door = preload("res://scenes/ExitDoor.tscn").instantiate()
	get_parent().add_child(exit_door)
	exit_door.global_position = tilemap.map_to_local(door_pos)

func get_player_spawn_position() -> Vector2:
	if rooms.is_empty():
		return Vector2.ZERO
	
	# Spawn player in the first room
	var first_room = rooms[0]
	var spawn_pos = Vector2i(
		first_room.position.x + first_room.size.x / 2,
		first_room.position.y + first_room.size.y / 2
	)
	
	return tilemap.map_to_local(spawn_pos)

func is_walkable_tile(world_position: Vector2) -> bool:
	var tile_pos = tilemap.local_to_map(world_position)
	var tile_data = tilemap.get_cell_atlas_coords(0, tile_pos)
	return tile_data == Vector2i(TileType.FLOOR, 0) or tile_data == Vector2i(TileType.DOOR, 0)
