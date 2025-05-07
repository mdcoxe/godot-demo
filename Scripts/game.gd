extends Control
@onready var coin: Label = $MarginContainer/VBoxContainer/top_half/vboxcontainer/stats_container/HBoxContainer/MarginContainer/coin
@onready var day: Label = $MarginContainer/VBoxContainer/top_half/vboxcontainer/stats_container/HBoxContainer/MarginContainer3/day

const SAVE_PATH = "user://save_game.cfg"

func _ready() -> void:
	_load_saved_game_data()

func _process(delta: float) -> void:
	pass

func _load_saved_game_data():
	coin.text = "Coins: " + str(SaveManager.get_coins())
	day.text = "Day: " + str(SaveManager.get_day())
	
func _on_button_main_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")

func _on_button_eod_pressed() -> void:
	SaveManager.add_day()
	day.text = "Day: " + str(SaveManager.get_day())

func _on_button_scavenge_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/dungeon.tscn")
