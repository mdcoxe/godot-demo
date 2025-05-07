extends Control

@onready var main_message: Label = $ColorRect/VBoxContainer/PanelContainer/MarginContainer/main_message
@onready var coin_total: Label = $ColorRect/VBoxContainer/PanelContainer2/HBoxContainer/MarginContainer/coin_total
@onready var message_label: Label = $ColorRect/VBoxContainer/PanelContainer2/HBoxContainer/MarginContainer2/message_label
@onready var button_stay: Button = $ColorRect/VBoxContainer/PanelContainer3/HBoxContainer/MarginContainer/button_stay
@onready var button_leave: Button = $ColorRect/VBoxContainer/PanelContainer3/HBoxContainer/MarginContainer2/button_leave
@onready var stay_button_container: MarginContainer = $ColorRect/VBoxContainer/PanelContainer3/HBoxContainer/stay_button_container

signal continue_pressed
signal exit_pressed

#Vars to store set-popup_data due to timing issues
var _popup_message: String = ""
var _popup_coins: int = 0
var _popup_main_message: String = ""
var button_check = 0
var button_text = ""

func _ready():
	if is_instance_valid(main_message):
		main_message.text = _popup_main_message
		
	if is_instance_valid(message_label):
		message_label.text = _popup_message
	else:
		print("Popup Warning: MessageLabel not found in _ready.")

	if is_instance_valid(coin_total):
		coin_total.text = "Coin Pouch: " + str(_popup_coins)
	else:
		print("Popup Warning: CoinsLabel not found in _ready.")
		
	if button_check == 1:
		stay_button_container.visible = false
		button_leave.text = button_text
	else:
		button_leave.text = "Exit Dungeon"
		stay_button_container.visible = true

		
func _on_button_leave_pressed() -> void:
	print("Exiting dungeon")
	exit_pressed.emit()
	button_check = 0
	queue_free()

func _on_button_stay_pressed() -> void:
	print("Continue Exploring")
	continue_pressed.emit()
	button_check = 0
	queue_free()

func set_popup_data(message: String, sub_message: String, coin: int, btns: int, btn_text: String):
	print("set popup data", coin)
	_popup_coins = coin
	_popup_main_message = message
	_popup_message = sub_message
	button_check = btns
	button_text = btn_text
