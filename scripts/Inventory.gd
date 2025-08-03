class_name Inventory
extends Control

signal item_used(item: Item)
signal item_equipped(item: Item)

@export var grid_size: Vector2i = Vector2i(8, 6)
@export var slot_size: Vector2 = Vector2(64, 64)

var inventory_slots: Array[InventorySlot] = []
var player: Player

@onready var grid_container: GridContainer = $Panel/GridContainer
@onready var equipped_weapon_slot: InventorySlot = $Panel/EquippedPanel/WeaponSlot
@onready var equipped_armor_slot: InventorySlot = $Panel/EquippedPanel/ArmorSlot
@onready var close_button: Button = $Panel/CloseButton

func _ready():
	setup_inventory_grid()
	close_button.pressed.connect(_on_close_button_pressed)
	visible = false

func setup_inventory_grid():
	grid_container.columns = grid_size.x
	
	# Create inventory slots
	for i in range(grid_size.x * grid_size.y):
		var slot = create_inventory_slot()
		grid_container.add_child(slot)
		inventory_slots.append(slot)

func create_inventory_slot() -> InventorySlot:
	var slot = preload("res://scenes/InventorySlot.tscn").instantiate()
	slot.item_dropped.connect(_on_item_dropped)
	slot.item_used.connect(_on_item_used)
	return slot

func set_player(new_player: Player):
	player = new_player

func add_item(item: Item) -> bool:
	# Find first empty slot
	for slot in inventory_slots:
		if not slot.has_item():
			slot.set_item(item)
			return true
	
	return false  # Inventory full

func remove_item(item: Item):
	for slot in inventory_slots:
		if slot.get_item() == item:
			slot.clear_item()
			break

func toggle_visibility():
	visible = not visible
	
	if visible:
		refresh_equipped_items()

func refresh_equipped_items():
	if not player:
		return
	
	equipped_weapon_slot.set_item(player.equipped_weapon)
	equipped_armor_slot.set_item(player.equipped_armor)

func _on_item_dropped(from_slot: InventorySlot, to_slot: InventorySlot):
	# Handle item swapping between slots
	var from_item = from_slot.get_item()
	var to_item = to_slot.get_item()
	
	from_slot.set_item(to_item)
	to_slot.set_item(from_item)

func _on_item_used(slot: InventorySlot, item: Item):
	if not player:
		return
	
	if item is HealthPotion:
		if item.use_item(player):
			slot.clear_item()
			item_used.emit(item)
	elif item is Weapon:
		equip_weapon(item)
		slot.clear_item()
	elif item is Armor:
		equip_armor(item)
		slot.clear_item()

func equip_weapon(weapon: Weapon):
	if not player:
		return
	
	# If player has equipped weapon, put it back in inventory
	if player.equipped_weapon:
		add_item(player.equipped_weapon)
	
	player.equip_weapon(weapon)
	equipped_weapon_slot.set_item(weapon)
	item_equipped.emit(weapon)

func equip_armor(armor: Armor):
	if not player:
		return
	
	# If player has equipped armor, put it back in inventory
	if player.equipped_armor:
		add_item(player.equipped_armor)
	
	player.equip_armor(armor)
	equipped_armor_slot.set_item(armor)
	item_equipped.emit(armor)

func _on_close_button_pressed():
	visible = false

func _input(event):
	if event.is_action_pressed("inventory"):
		toggle_visibility()
