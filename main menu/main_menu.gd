class_name MainMenu
extends Control


@onready var new_game_button = $MarginContainer/HBoxContainer/VBoxContainer/Start_Button as Button
@onready var exit_button = $MarginContainer/HBoxContainer/VBoxContainer/Exit_Button as Button
@onready var continue_button = $MarginContainer/HBoxContainer/VBoxContainer/Continue_Button as Button
@onready var Player = $Player

func _ready():
	new_game_button.button_down.connect(on_new_game_pressed)
	exit_button.button_down.connect(on_exit_pressed)
	continue_button.button_down.connect(on_continue_pressed)

func on_new_game_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/environment/world.tscn")
	
func on_exit_pressed() -> void:
	get_tree().quit()

func on_continue_pressed() -> void:
		Player.load_data()
