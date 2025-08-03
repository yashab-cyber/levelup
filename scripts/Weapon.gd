class_name Weapon
extends Item

@export var damage: int = 10
@export var attack_speed: float = 1.0
@export var range: float = 50.0
@export var weapon_type: WeaponType = WeaponType.SWORD

enum WeaponType {
	SWORD,
	STAFF,
	DAGGER,
	BOW
}

func _init():
	name = "Basic Sword"
	description = "A simple iron sword"
	damage = 10
	rarity = Rarity.COMMON

func get_weapon_type_name() -> String:
	match weapon_type:
		WeaponType.SWORD:
			return "Sword"
		WeaponType.STAFF:
			return "Staff"
		WeaponType.DAGGER:
			return "Dagger"
		WeaponType.BOW:
			return "Bow"
		_:
			return "Unknown"

static func generate_random_weapon(floor_level: int) -> Weapon:
	var weapon = Weapon.new()
	var base_damage = 5 + floor_level * 3
	
	# Random weapon type
	weapon.weapon_type = WeaponType.values()[randi() % WeaponType.size()]
	
	# Random rarity (higher floor = better chance for rare items)
	var rarity_roll = randf()
	if rarity_roll < 0.05 + floor_level * 0.01:
		weapon.rarity = Rarity.LEGENDARY
		weapon.damage = base_damage * 3
	elif rarity_roll < 0.15 + floor_level * 0.02:
		weapon.rarity = Rarity.EPIC
		weapon.damage = base_damage * 2
	elif rarity_roll < 0.3 + floor_level * 0.03:
		weapon.rarity = Rarity.RARE
		weapon.damage = int(base_damage * 1.5)
	elif rarity_roll < 0.6:
		weapon.rarity = Rarity.UNCOMMON
		weapon.damage = int(base_damage * 1.2)
	else:
		weapon.rarity = Rarity.COMMON
		weapon.damage = base_damage
	
	# Set name based on type and rarity
	weapon.name = _get_weapon_name(weapon.weapon_type, weapon.rarity)
	weapon.description = "A " + weapon.get_rarity_color().to_html() + " " + weapon.get_weapon_type_name().to_lower()
	
	return weapon

static func _get_weapon_name(type: WeaponType, rarity: Rarity) -> String:
	var rarity_prefix = ""
	match rarity:
		Rarity.UNCOMMON:
			rarity_prefix = "Fine "
		Rarity.RARE:
			rarity_prefix = "Superior "
		Rarity.EPIC:
			rarity_prefix = "Masterwork "
		Rarity.LEGENDARY:
			rarity_prefix = "Legendary "
	
	var weapon_name = ""
	match type:
		WeaponType.SWORD:
			weapon_name = "Sword"
		WeaponType.STAFF:
			weapon_name = "Staff"
		WeaponType.DAGGER:
			weapon_name = "Dagger"
		WeaponType.BOW:
			weapon_name = "Bow"
	
	return rarity_prefix + weapon_name
