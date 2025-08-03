class_name InventorySlot
extends Control

signal item_dropped(from_slot: InventorySlot, to_slot: InventorySlot)
signal item_used(slot: InventorySlot, item: Item)

var item: Item = null

@onready var item_icon: TextureRect = $ItemIcon
@onready var quantity_label: Label = $QuantityLabel
@onready var button: Button = $Button

func _ready():
	button.pressed.connect(_on_button_pressed)
	
	# Setup drag and drop (simplified version)
	button.gui_input.connect(_on_button_gui_input)

func _on_button_pressed():
	if item:
		item_used.emit(self, item)

func _on_button_gui_input(event):
	# Handle drag and drop here
	pass

func set_item(new_item: Item):
	item = new_item
	update_display()

func get_item() -> Item:
	return item

func has_item() -> bool:
	return item != null

func clear_item():
	item = null
	update_display()

func update_display():
	if item:
		if item.icon:
			item_icon.texture = item.icon
		else:
			item_icon.texture = null
		
		item_icon.visible = true
		quantity_label.visible = false  # For now, no stacking
		
		# Set tooltip
		button.tooltip_text = item.name + "\n" + item.description
	else:
		item_icon.visible = false
		quantity_label.visible = false
		button.tooltip_text = ""
