class_name Item
extends Resource

@export var name: String = "Item"
@export var description: String = "A basic item"
@export var icon: Texture2D
@export var rarity: Rarity = Rarity.COMMON
@export var value: int = 10

enum Rarity {
	COMMON,
	UNCOMMON,
	RARE,
	EPIC,
	LEGENDARY
}

func get_rarity_color() -> Color:
	match rarity:
		Rarity.COMMON:
			return Color.WHITE
		Rarity.UNCOMMON:
			return Color.GREEN
		Rarity.RARE:
			return Color.BLUE
		Rarity.EPIC:
			return Color.PURPLE
		Rarity.LEGENDARY:
			return Color.ORANGE
		_:
			return Color.WHITE

func use_item(player: Player) -> bool:
	# Override in subclasses
	return false
