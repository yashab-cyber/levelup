class_name Armor
extends Item

@export var defense: int = 5
@export var armor_type: ArmorType = ArmorType.LIGHT

enum ArmorType {
	LIGHT,
	MEDIUM,
	HEAVY
}

func _init():
	name = "Basic Armor"
	description = "Simple leather armor"
	defense = 5
	rarity = Rarity.COMMON

func get_armor_type_name() -> String:
	match armor_type:
		ArmorType.LIGHT:
			return "Light Armor"
		ArmorType.MEDIUM:
			return "Medium Armor"
		ArmorType.HEAVY:
			return "Heavy Armor"
		_:
			return "Unknown"

static func generate_random_armor(floor_level: int) -> Armor:
	var armor = Armor.new()
	var base_defense = 3 + floor_level * 2
	
	# Random armor type
	armor.armor_type = ArmorType.values()[randi() % ArmorType.size()]
	
	# Random rarity (higher floor = better chance for rare items)
	var rarity_roll = randf()
	if rarity_roll < 0.05 + floor_level * 0.01:
		armor.rarity = Rarity.LEGENDARY
		armor.defense = base_defense * 3
	elif rarity_roll < 0.15 + floor_level * 0.02:
		armor.rarity = Rarity.EPIC
		armor.defense = base_defense * 2
	elif rarity_roll < 0.3 + floor_level * 0.03:
		armor.rarity = Rarity.RARE
		armor.defense = int(base_defense * 1.5)
	elif rarity_roll < 0.6:
		armor.rarity = Rarity.UNCOMMON
		armor.defense = int(base_defense * 1.2)
	else:
		armor.rarity = Rarity.COMMON
		armor.defense = base_defense
	
	# Set name based on type and rarity
	armor.name = _get_armor_name(armor.armor_type, armor.rarity)
	armor.description = "A " + armor.get_rarity_color().to_html() + " " + armor.get_armor_type_name().to_lower()
	
	return armor

static func _get_armor_name(type: ArmorType, rarity: Rarity) -> String:
	var rarity_prefix = ""
	match rarity:
		Rarity.UNCOMMON:
			rarity_prefix = "Reinforced "
		Rarity.RARE:
			rarity_prefix = "Enchanted "
		Rarity.EPIC:
			rarity_prefix = "Mastercraft "
		Rarity.LEGENDARY:
			rarity_prefix = "Legendary "
	
	var armor_name = ""
	match type:
		ArmorType.LIGHT:
			armor_name = "Leather Armor"
		ArmorType.MEDIUM:
			armor_name = "Chain Mail"
		ArmorType.HEAVY:
			armor_name = "Plate Armor"
	
	return rarity_prefix + armor_name
