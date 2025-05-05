extends Control
@onready var button_continue: Button = $MarginContainer/VBoxContainer/button_container/button_continue
@onready var button_play: Button = $MarginContainer/VBoxContainer/button_container/button_play
@onready var button_exit: Button = $MarginContainer/VBoxContainer/button_container/button_exit

const SAVE_PATH = "user://save_game.cfg"

func _ready() -> void:
	_update_continue_button()

func _process(delta: float) -> void:
	pass

func _update_continue_button():
	var cfg = ConfigFile.new()
	var err = cfg.load(SAVE_PATH)
	if err == OK and cfg.has_section_key("progress", "has_save") and cfg.get_value("progress", "has_save"):
		button_continue.visible = true
	else:
		button_continue.visible = false

func _create_new_save():
	var cfg = ConfigFile.new()
	
	cfg.set_value("progress", "has_save", true)
	cfg.set_value("game", "coins", 4000)
	cfg.set_value("game", "day", 1)
	cfg.set_value("game", "level", 1)
	
	var err = cfg.save(SAVE_PATH)
	if err != OK:
		print("Error saving new game data:", err)


func _on_button_play_pressed() -> void:
	print("Starting new game ...")
	_create_new_save()
	get_tree().change_scene_to_file("res://game.tscn")

func _on_button_continue_pressed() -> void:
	print("Continuing existing game ...")
	get_tree().change_scene_to_file("res://game.tscn")

func _on_button_exit_pressed() -> void:
	get_tree().quit()

#temporary button function
func _on_button_extras_pressed() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		var dir = DirAccess.open("user://")
		if dir:
			var err = dir.remove("save_game.cfg")
			if err == OK:
				print("Save file deleted successfully.")
			else:
				print("Failed to delete save file. Error code:", err)
		else:
			print("Failed to open user directory.")
	else:
		print("No save file to delete.")
