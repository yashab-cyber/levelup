class_name MainMenu
extends Control

@onready var start_button: Button = $VBoxContainer/StartButton
@onready var load_button: Button = $VBoxContainer/LoadButton
@onready var settings_button: Button = $VBoxContainer/SettingsButton
@onready var quit_button: Button = $VBoxContainer/QuitButton
@onready var title_label: Label = $TitleLabel

func _ready():
	# Connect buttons
	start_button.pressed.connect(_on_start_button_pressed)
	load_button.pressed.connect(_on_load_button_pressed)
	settings_button.pressed.connect(_on_settings_button_pressed)
	quit_button.pressed.connect(_on_quit_button_pressed)
	
	# Check if save file exists
	load_button.disabled = not GameManager.has_save_file()

func _on_start_button_pressed():
	GameManager.start_new_game()

func _on_load_button_pressed():
	GameManager.load_game()

func _on_settings_button_pressed():
	# TODO: Implement settings menu
	print("Settings not implemented yet")

func _on_quit_button_pressed():
	get_tree().quit()
