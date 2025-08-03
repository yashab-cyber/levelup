class_name SkillTree
extends Control

signal skill_unlocked(skill: Skill)

var player: Player
var skills: Array[Skill] = []
var skill_points: int = 0

@onready var skill_grid: GridContainer = $Panel/SkillGrid
@onready var skill_points_label: Label = $Panel/SkillPointsLabel
@onready var close_button: Button = $Panel/CloseButton

func _ready():
	setup_skills()
	close_button.pressed.connect(_on_close_button_pressed)
	visible = false

func setup_skills():
	# Create skill definitions
	var sword_mastery = Skill.new()
	sword_mastery.name = "Sword Mastery"
	sword_mastery.description = "Increases sword damage by 25%"
	sword_mastery.required_level = 3
	sword_mastery.skill_type = Skill.SkillType.COMBAT
	
	var health_boost = Skill.new()
	health_boost.name = "Vitality"
	health_boost.description = "Increases max health by 50"
	health_boost.required_level = 2
	health_boost.skill_type = Skill.SkillType.DEFENSE
	
	var dash = Skill.new()
	dash.name = "Dash"
	dash.description = "Unlocks dash ability (Shift key)"
	dash.required_level = 4
	dash.skill_type = Skill.SkillType.MOVEMENT
	
	var fireball = Skill.new()
	fireball.name = "Fireball"
	fireball.description = "Unlocks fireball spell"
	fireball.required_level = 5
	fireball.skill_type = Skill.SkillType.MAGIC
	
	var critical_strike = Skill.new()
	critical_strike.name = "Critical Strike"
	critical_strike.description = "15% chance for critical hits"
	critical_strike.required_level = 6
	critical_strike.skill_type = Skill.SkillType.COMBAT
	
	var magic_shield = Skill.new()
	magic_shield.name = "Magic Shield"
	magic_shield.description = "Absorbs 3 hits before breaking"
	magic_shield.required_level = 7
	magic_shield.skill_type = Skill.SkillType.MAGIC
	
	skills = [sword_mastery, health_boost, dash, fireball, critical_strike, magic_shield]
	
	# Create skill buttons
	for skill in skills:
		create_skill_button(skill)

func create_skill_button(skill: Skill):
	var button = Button.new()
	button.text = skill.name
	button.custom_minimum_size = Vector2(150, 100)
	button.disabled = true
	
	# Color based on skill type
	match skill.skill_type:
		Skill.SkillType.COMBAT:
			button.modulate = Color.RED
		Skill.SkillType.DEFENSE:
			button.modulate = Color.BLUE
		Skill.SkillType.MOVEMENT:
			button.modulate = Color.GREEN
		Skill.SkillType.MAGIC:
			button.modulate = Color.PURPLE
	
	button.pressed.connect(_on_skill_button_pressed.bind(skill, button))
	skill_grid.add_child(button)
	
	# Store button reference in skill
	skill.button = button

func set_player(new_player: Player):
	player = new_player
	player.level_up.connect(_on_player_level_up)
	update_skill_availability()

func _on_player_level_up(new_level: int):
	skill_points += 1
	update_skill_availability()

func update_skill_availability():
	if not player:
		return
	
	skill_points_label.text = "Skill Points: " + str(skill_points)
	
	for skill in skills:
		if skill.is_unlocked:
			skill.button.modulate.a = 1.0
			skill.button.disabled = true
			skill.button.text = skill.name + "\n[UNLOCKED]"
		elif player.level >= skill.required_level and skill_points > 0:
			skill.button.modulate.a = 1.0
			skill.button.disabled = false
			skill.button.text = skill.name + "\nLevel " + str(skill.required_level)
		else:
			skill.button.modulate.a = 0.5
			skill.button.disabled = true
			skill.button.text = skill.name + "\nLevel " + str(skill.required_level)

func _on_skill_button_pressed(skill: Skill, button: Button):
	if skill_points <= 0 or skill.is_unlocked:
		return
	
	# Unlock skill
	skill.is_unlocked = true
	skill_points -= 1
	
	# Apply skill effect
	apply_skill_effect(skill)
	
	# Update UI
	update_skill_availability()
	skill_unlocked.emit(skill)

func apply_skill_effect(skill: Skill):
	if not player:
		return
	
	match skill.name:
		"Sword Mastery":
			player.attack_power = int(player.attack_power * 1.25)
		"Vitality":
			player.max_health += 50
			player.current_health += 50
			player.health_changed.emit(player.current_health, player.max_health)
		"Dash":
			player.set("has_dash", true)
		"Fireball":
			player.set("has_fireball", true)
		"Critical Strike":
			player.set("crit_chance", 0.15)
		"Magic Shield":
			player.set("has_magic_shield", true)

func _on_close_button_pressed():
	visible = false
