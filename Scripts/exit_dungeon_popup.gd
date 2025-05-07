extends Control
@onready var button_stay: Button = $ColorRect/VBoxContainer/PanelContainer3/HBoxContainer/MarginContainer/button_stay
@onready var button_leave: Button = $ColorRect/VBoxContainer/PanelContainer3/HBoxContainer/MarginContainer2/button_leave
@onready var coin_total: Label = $ColorRect/VBoxContainer/PanelContainer2/HBoxContainer/MarginContainer/coin_total
@onready var message_label: Label = $ColorRect/VBoxContainer/PanelContainer2/HBoxContainer/MarginContainer2/message_label

signal continue_pressed
signal exit_pressed

#Vars to store set-popup_data due to timing issues
var _popup_message: String = ""
var _popup_coins: int = 0

func _ready():
	if is_instance_valid(message_label):
		message_label.text = _popup_message
		print("Popup: Message label text set in _ready.")
	else:
		print("Popup Warning: MessageLabel not found in _ready.")

	if is_instance_valid(coin_total):
		coin_total.text = "Coins Found: " + str(_popup_coins)
		print("Popup: Coins label text set in _ready.")
	else:
		print("Popup Warning: CoinsLabel not found in _ready.")

func _on_button_leave_pressed() -> void:
	print("Exiting dungeon")
	exit_pressed.emit()
	queue_free()

func _on_button_stay_pressed() -> void:
	print("Continue Exploring")
	continue_pressed.emit()
	queue_free()

func set_popup_data(message, coin: int):
	print("set popup data", coin)
	_popup_coins = coin
	_popup_message = message
