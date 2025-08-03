class_name Combat
extends Node

# Combat calculation utilities and damage formulas

static func calculate_damage(attacker_power: int, defender_defense: int, weapon_damage: int = 0) -> int:
	var base_damage = attacker_power + weapon_damage
	var mitigated_damage = max(1, base_damage - defender_defense)
	
	# Add some randomness (±20%)
	var variance = mitigated_damage * 0.2
	var final_damage = mitigated_damage + randf_range(-variance, variance)
	
	return max(1, int(final_damage))

static func calculate_critical_hit(base_damage: int, crit_chance: float = 0.1) -> int:
	if randf() < crit_chance:
		return int(base_damage * 1.5)  # 50% more damage on crit
	return base_damage

static func calculate_level_up_stats(current_level: int) -> Dictionary:
	return {
		"health_bonus": 15 + current_level * 5,
		"attack_bonus": 3 + current_level * 2,
		"defense_bonus": 2 + current_level,
		"xp_requirement": int(100 * pow(1.15, current_level))
	}

static func get_status_effect_duration(effect_type: String) -> float:
	match effect_type:
		"poison":
			return 5.0
		"burn":
			return 3.0
		"freeze":
			return 2.0
		"stun":
			return 1.0
		_:
			return 1.0
