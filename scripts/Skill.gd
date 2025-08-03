class_name Skill
extends Resource

@export var name: String = "Skill"
@export var description: String = "A skill"
@export var required_level: int = 1
@export var skill_type: SkillType = SkillType.COMBAT
@export var is_unlocked: bool = false

var button: Button  # Reference to UI button

enum SkillType {
	COMBAT,
	DEFENSE,
	MOVEMENT,
	MAGIC
}
