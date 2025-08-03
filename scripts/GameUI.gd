class_name GameUI
extends Control

@onready var health_bar: ProgressBar = $HealthBar
@onready var health_label: Label = $HealthBar/HealthLabel
@onready var xp_bar: ProgressBar = $XPBar
@onready var xp_label: Label = $XPBar/XPLabel
@onready var level_label: Label = $LevelLabel
@onready var inventory: Inventory = $Inventory
@onready var skill_tree: SkillTree = $SkillTree
@onready var pause_menu: Control = $PauseMenu
@onready var game_over_screen: Control = $GameOverScreen

var player: Player
var is_paused: bool = false

func _ready():
	# Initially hide all menus
	inventory.visible = false
	skill_tree.visible = false
	pause_menu.visible = false
	game_over_screen.visible = false

func setup_player(new_player: Player):
	player = new_player
	inventory.set_player(player)
	skill_tree.set_player(player)
	
	# Connect player signals
	player.health_changed.connect(_on_player_health_changed)
	player.xp_changed.connect(_on_player_xp_changed)
	player.level_up.connect(_on_player_level_up)
	player.died.connect(_on_player_died)
	
	# Initialize UI
	_on_player_health_changed(player.current_health, player.max_health)
	_on_player_xp_changed(player.current_xp, player.xp_to_next_level)
	level_label.text = "Level " + str(player.level)

func _input(event):
	if event.is_action_pressed("inventory"):
		toggle_inventory()
	
	if event.is_action_pressed("skill_tree"):
		toggle_skill_tree()
	
	if event.is_action_pressed("pause"):
		toggle_pause_menu()

func toggle_inventory():
	inventory.visible = not inventory.visible
	
	if inventory.visible:
		skill_tree.visible = false

func toggle_skill_tree():
	skill_tree.visible = not skill_tree.visible
	
	if skill_tree.visible:
		inventory.visible = false

func toggle_pause_menu():
	is_paused = not is_paused
	pause_menu.visible = is_paused
	
	if is_paused:
		get_tree().paused = true
		inventory.visible = false
		skill_tree.visible = false
	else:
		get_tree().paused = false

func _on_player_health_changed(current_health: int, max_health: int):
	health_bar.max_value = max_health
	health_bar.value = current_health
	health_label.text = str(current_health) + "/" + str(max_health)
	
	# Change color based on health percentage
	var health_percent = float(current_health) / float(max_health)
	if health_percent > 0.6:
		health_bar.modulate = Color.GREEN
	elif health_percent > 0.3:
		health_bar.modulate = Color.YELLOW
	else:
		health_bar.modulate = Color.RED

func _on_player_xp_changed(current_xp: int, xp_to_next_level: int):
	xp_bar.max_value = xp_to_next_level
	xp_bar.value = current_xp
	xp_label.text = str(current_xp) + "/" + str(xp_to_next_level) + " XP"

func _on_player_level_up(new_level: int):
	level_label.text = "Level " + str(new_level)
	
	# Show level up effect
	show_level_up_effect()

func show_level_up_effect():
	var level_up_label = Label.new()
	level_up_label.text = "LEVEL UP!"
	level_up_label.add_theme_font_size_override("font_size", 48)
	level_up_label.modulate = Color.GOLD
	level_up_label.position = Vector2(640, 200)  # Center of screen
	add_child(level_up_label)
	
	# Animate the label
	var tween = create_tween()
	tween.parallel().tween_property(level_up_label, "position:y", 150, 1.0)
	tween.parallel().tween_property(level_up_label, "modulate:a", 0.0, 1.0)
	tween.tween_callback(level_up_label.queue_free)

func _on_player_died():
	show_game_over_screen()

func show_game_over_screen():
	game_over_screen.visible = true
	get_tree().paused = true

func hide_all_menus():
	inventory.visible = false
	skill_tree.visible = false
	pause_menu.visible = false
	is_paused = false
