extends Control
@onready var coin: Label = $MarginContainer/VBoxContainer/top_half/vboxcontainer/stats_container/HBoxContainer/MarginContainer/coin
@onready var day: Label = $MarginContainer/VBoxContainer/top_half/vboxcontainer/stats_container/HBoxContainer/MarginContainer3/day

const SAVE_PATH = "user://save_game.cfg"
var days_passed = 0 

func _ready() -> void:
	_load_saved_game_data()

func _process(delta: float) -> void:
	pass

func _load_saved_game_data():
	var cfg = ConfigFile.new()
	var err = cfg.load(SAVE_PATH)
	if err != OK:
		print("Failed to load save file:", err)
		return
	var coins = cfg.get_value("game", "coins", 0)
	days_passed = cfg.get_value("game", "day", 1)
	
	coin.text = "Coins: " + str(coins)
	day.text = "Day: " + str(days_passed)
	
func _update_days(days):
	var cfg = ConfigFile.new()
	var err = cfg.load(SAVE_PATH)
	if err != OK:
		print("Failed to save file:", err)
		return
	cfg.set_value("game", "day", days)
	cfg.save(SAVE_PATH)


func _on_button_main_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://main_menu.tscn")


func _on_button_eod_pressed() -> void:
	days_passed += 1
	
	_update_days(days_passed)
	day.text = "Day: " + str(days_passed)


func _on_button_scavenge_pressed() -> void:
	get_tree().change_scene_to_file("res://dungeon.tscn")
