class_name HealthPotion
extends Item

@export var heal_amount: int = 50

func _init():
	name = "Health Potion"
	description = "Restores health when consumed"
	heal_amount = 50
	rarity = Rarity.COMMON

func use_item(player: Player) -> bool:
	if player.current_health < player.max_health:
		player.heal(heal_amount)
		return true  # Item was consumed
	return false  # Item was not used
