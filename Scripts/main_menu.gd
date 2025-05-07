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
	button_continue.visible = SaveManager.save_file_exists()

func _on_button_play_pressed() -> void:
	print("Starting new game ...")
	SaveManager.create_new_save()
	get_tree().change_scene_to_file("res://Scenes/game.tscn")

func _on_button_continue_pressed() -> void:
	print("Continuing existing game ...")
#	maybe needs to return to previous spot, use as pause screen? Would need game state persistence loaded...but can't work with dungeon...maybe needs a penalty for getting rescued from dungeon before finding exit
	get_tree().change_scene_to_file("res://Scenes/game.tscn")

func _on_button_exit_pressed() -> void:
	get_tree().quit()

#temporary button function
func _on_button_extras_pressed() -> void:
	SaveManager.delete_save_file()
	_update_continue_button()
