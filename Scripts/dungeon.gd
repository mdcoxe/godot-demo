extends Control
@onready var grid_container: GridContainer = $MarginContainer/VBoxContainer/PanelContainer/VBoxContainer/Dungeon_Panel/MarginContainer/GridContainer
@onready var coin_pouch_label: Label = $MarginContainer/VBoxContainer/PanelContainer/VBoxContainer/Stats_Panel/HBoxContainer/MarginContainer/coin_pouch_label
@onready var item_count_label: Label = $MarginContainer/VBoxContainer/PanelContainer/VBoxContainer/Stats_Panel/HBoxContainer/MarginContainer2/item_count_label
@onready var day_label: Label = $MarginContainer/VBoxContainer/PanelContainer/VBoxContainer/Stats_Panel/HBoxContainer/MarginContainer3/day_label
@onready var message_label: Label = $MarginContainer/VBoxContainer/PanelContainer2/Bottom_Panel/Message/message_label
@onready var sub_message_label: Label = $MarginContainer/VBoxContainer/PanelContainer2/Bottom_Panel/SubMessage/sub_message_label
@onready var event_img: ColorRect = $CanvasLayer/event_img
@onready var event_icon: TextureRect = $CanvasLayer/event_img/event_icon
@onready var continue_button: MarginContainer = $MarginContainer/VBoxContainer/PanelContainer2/Bottom_Panel/ContinueButton
@onready var exit_button: MarginContainer = $MarginContainer/VBoxContainer/PanelContainer2/Bottom_Panel/ExitButton

#const EventPopupScene = preload("res://Scenes/dungeon_event_popup.tscn")
const ENTRANCE_ICON = preload("res://assets/icons/function_icon_store_1.png")
const PLAYER_ICON = preload("res://assets/icons/function_icon_assassin.png")
const EXIT_ICON = preload("res://assets/coloricons/key-hole.png")
const LOOT_ICON = preload("res://assets/icons/function_icon_moneybag.png")
const ENEMY_ICON = preload("res://assets/icons/function_icon_battle.png")
const TRAP_ICON = preload("res://assets/icons/function_icon_death.png")
const GRID_SIZE = Vector2i(7,4)

var tile_buttons := {}
var tile_data := {}
var player_position: Vector2i
var coin_pouch : int 
var default_style = StyleBoxFlat.new()
var empty_style = StyleBoxFlat.new()

func _ready():
	default_style.bg_color = Color(0.2, 0.2, 0.2) # Dark grey for disabled/unrevealed
	empty_style.bg_color = Color(0.4, 0.4, 0.4)    # Lighter grey for empty visited

	_create_grid()
	generate_dungeon()
	await get_tree().process_frame

	_reveal_tile(player_position)
	_update_clickable_tiles()


func _reveal_tile(pos):
	var btn = tile_buttons.get(pos)

	if not btn: return
	if not tile_data.has(pos): return

	var data = tile_data[pos]

	if data.revealed:
		_apply_button_style(btn, empty_style) 
	else:
		_apply_button_style(btn, default_style)
	
	if pos == player_position:
		btn.icon = PLAYER_ICON
	elif data.revealed:
		match data.type:
			"entrance":
				btn.icon = ENTRANCE_ICON
			"exit":
				btn.icon = EXIT_ICON
			"loot":
				btn.icon = LOOT_ICON
			"trap":
				btn.icon = TRAP_ICON
			"enemy":
				btn.icon = ENEMY_ICON
			_:
				btn.icon = null
	else:
		btn.icon = null


func _apply_button_style(btn: Button, style: StyleBox):
	btn.add_theme_stylebox_override("normal", style)
	btn.add_theme_stylebox_override("pressed", style)
	btn.add_theme_stylebox_override("hover", style)
	btn.add_theme_stylebox_override("disabled", style) 

func generate_dungeon():
	tile_data.clear()
	var positions := []
	coin_pouch = 0
	_update_coin_pouch_label(coin_pouch)
	for y in range(GRID_SIZE.y):
			for x in range(GRID_SIZE.x):
					var pos = Vector2i(x,y)
					tile_data[pos] = {
							"type": "empty",
							"revealed": false
					}
					positions.append(pos)
	positions.shuffle()

	var entrance = positions.pop_front()
	var exit = positions.pop_front()
	tile_data[entrance].type = "entrance"
	tile_data[entrance].revealed = true
	player_position = entrance
	tile_data[exit].type = "exit"

	for i in range(3): tile_data[positions.pop_front()].type = "loot"
	for i in range(randi_range(1,2)): tile_data[positions.pop_front()].type = "trap"
	for i in range(randi_range(1,2)): tile_data[positions.pop_front()].type = "enemy"

func _create_grid():
	grid_container.columns = GRID_SIZE.x
	var button_font = get_theme_font("font")
	var max_icon_pixel_size = 90
	for y in range(GRID_SIZE.y):
		for x in range(GRID_SIZE.x):
			var pos = Vector2i(x,y)
			var wrapper = AspectRatioContainer.new()
			wrapper.ratio = 1.0
			wrapper.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			wrapper.size_flags_vertical = Control.SIZE_EXPAND_FILL

			var btn = Button.new()
			btn.text = ""
			btn.name = "Tile_%d_%d" % [x,y]

			btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			btn.size_flags_vertical = Control.SIZE_EXPAND_FILL

			btn.add_theme_stylebox_override("normal", default_style)
			btn.add_theme_stylebox_override("pressed", default_style)
			btn.add_theme_stylebox_override("hover", default_style)
			btn.add_theme_stylebox_override("disabled", default_style) 
			btn.disabled = true 
			btn.mouse_filter = Control.MOUSE_FILTER_IGNORE
			
			btn.add_theme_constant_override("icon_max_width", max_icon_pixel_size)
			btn.add_theme_constant_override("icon_max_height", max_icon_pixel_size)
			btn.expand_icon = true
			btn.add_theme_color_override("icon_normal_color", Color(.6,.6,.6))
			btn.add_theme_color_override("icon_hover_color", Color(.6,.6,.6))
			btn.add_theme_color_override("icon_pressed_color", Color(.6,.6,.6))
			btn.add_theme_color_override("icon_disabled_color", Color(.6,.6,.6)) 

			btn.pressed.connect(_on_tile_pressed.bind(pos, btn))

			wrapper.add_child(btn)
			grid_container.add_child(wrapper)
			tile_buttons[pos] = btn

func _get_adjacent_positions(pos: Vector2i) -> Array[Vector2i]:
	var adjacent_offsets = [Vector2i(0, -1), Vector2i(0, 1), Vector2i(-1, 0), Vector2i(1, 0)] # N, S, W, E
	var valid_adjacent_positions: Array[Vector2i] = []

	for offset in adjacent_offsets:
		var neighbor_pos = pos + offset
		# Check if the neighbor position is within grid bounds
		if neighbor_pos.x >= 0 and neighbor_pos.x < GRID_SIZE.x and neighbor_pos.y >= 0 and neighbor_pos.y < GRID_SIZE.y:
			valid_adjacent_positions.append(neighbor_pos)
	return valid_adjacent_positions

func _update_clickable_tiles():
	var adjacent_positions = _get_adjacent_positions(player_position)

	for pos in tile_buttons.keys():
		var btn = tile_buttons[pos]
		if pos in adjacent_positions:
			btn.disabled = false
			btn.mouse_filter = Control.MOUSE_FILTER_STOP
			_reveal_tile(pos)
		else:
			btn.disabled = true
			btn.mouse_filter = Control.MOUSE_FILTER_IGNORE
			_reveal_tile(pos)

func _on_tile_pressed(pos: Vector2i, btn: Button):
	print("Tile pressed:", pos)

	var valid_moves = _get_adjacent_positions(player_position)
	if pos in valid_moves:
		# This is a valid move
		var old_player_position = player_position
		player_position = pos 

		print("Player moved to:", player_position)

		if tile_data.has(player_position) and not tile_data[player_position].revealed:
			tile_data[player_position].revealed = true

		_reveal_tile(player_position)
		_reveal_tile(old_player_position)
		_update_clickable_tiles()

		match tile_data[player_position].type:
			"exit":
				event_icon.texture = EXIT_ICON
				event_img.visible = true
				var message = "The dungeon exit is within reach. You may depart now with your accumulated spoils, or venture further into the depths at your own peril for the chance of richer rewards." #maybe add a damage or damage the loot
				var message2 = ""
				print("You're leaving the dungeon with ", coin_pouch, " coins!!")
				_event_triggered(message, message2, 1)
				#show_exit_popup(coin_pouch)
			"loot":
				event_icon.texture = LOOT_ICON
				event_img.visible = true
				var loot = randi_range(10,100)
				print("Found ", loot, " coins!")
				coin_pouch += loot
				_update_coin_pouch_label(coin_pouch)
				var message = "You came across a small pile of coins likely cut from a fallen raider"
				var message2 = "You added " + str(loot) + " to your coin pouch"
				_event_triggered(message, message2, 0)
				#show_event_popup(message, message2, coin_pouch)
				# Handle loot (e.g., add to inventory)
			"trap":
				event_icon.texture = TRAP_ICON
				event_img.visible = true
				var message = "You fell into a trap!  While crawling free your pack got snagged on a spike." #maybe add a damage or damage the loot
				var message2 = ""
				var lost_coins = 0
				if coin_pouch >=25:
					var lost_percentage = (randi() % 80) * .01
					print("Lost coin: ", lost_coins)
					lost_coins = int(coin_pouch * lost_percentage)
					coin_pouch -= lost_coins
					message2 = str(int(lost_coins)) + "coins fell out of your coin pouch!!  You managed to snatch the bag shut before more were lost."
				else:
					message2 = "You lost your coin pouch"
					coin_pouch = 0
				_update_coin_pouch_label(coin_pouch)
				_event_triggered(message, message2, 0)
				#show_event_popup(message, message2, coin_pouch)
			"enemy":
				event_icon.texture = ENEMY_ICON
				event_img.visible = true
				var message = "You spot the remenants of a failed raiding parties camp,nearby looters wave knowing you're here doing the same, looting the dead."
				var message2 = "While venturing along the edge of the camp, you spot a small chest that appears hastily buried.  You stuff it into your pack and hope the othr looters don't notice you."
				_event_triggered(message, message2, 0)
#				add item to pack
				#combat isn't real combat, maybe roll to decide if you are able to steal their loot or they steal from you before you can get away from each other.
			_:
				pass 



#func show_event_popup(main_message: String, sub_message: String, coin: int, ):
	#var event_popup_instance = EventPopupScene.instantiate()
	#
	#event_popup_instance.exit_pressed.connect(_exit_event_popup)
	#event_popup_instance.set_popup_data(main_message, sub_message, coin, 1, "Continue Exploring")
	#add_child(event_popup_instance)
	#
#func _exit_event_popup():
	#print("Event complete")
	#get_tree().paused = false

#func show_exit_popup(coin_amount: int):
	#var exit_popup_instance = EventPopupScene.instantiate()
	#
	#exit_popup_instance.continue_pressed.connect(_on_exit_popup_continue)
	#exit_popup_instance.exit_pressed.connect(_on_exit_popup_exit)
	#
	#var message = "The dungeon exit is within reach. You may depart now with your accumulated spoils, or venture further into the depths at your own peril for the chance of richer rewards."
	#print("COIN AMOUNT", + coin_amount)
	#exit_popup_instance.set_popup_data(message, "", coin_amount, 2, "Exit Dungeon")
	#add_child(exit_popup_instance)
	
#func _on_exit_popup_continue():
	#print("Main Scene: User chose to continue exploring.")
	#get_tree().paused = false

#func _on_exit_popup_exit():
	#print("Main Scene: User chose to exit the dungeon.")
	#SaveManager.add_coins(coin_pouch)
	#coin_pouch = 0
	#_update_coin_pouch_label(coin_pouch)
	#get_tree().paused = false
	#get_tree().change_scene_to_file("res://Scenes/game.tscn")

func _update_coin_pouch_label(coin: int):
	coin_pouch_label.text = "Coin Pouch: " + str(coin)

#trigger event, flag determines the visible items
func _event_triggered(msg, submsg, flag):
	message_label.text = msg
	sub_message_label.text = submsg
	if flag == 0:
		continue_button.visible = true
	elif flag ==1:
		continue_button.visible = true
		exit_button.visible = true

#Reset the event info
func _on_button_continue_pressed() -> void:
	message_label.text = ""
	sub_message_label.text = ""
	event_img.visible = false
	event_icon.texture = null
	continue_button.visible = false
	exit_button.visible = false

func _on_button_exit_pressed() -> void:
	print("Main Scene: User chose to exit the dungeon.")
	SaveManager.add_coins(coin_pouch)
	coin_pouch = 0
	_update_coin_pouch_label(coin_pouch)
	get_tree().change_scene_to_file("res://Scenes/game.tscn")

func _on_button_main_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")

func _on_button_return_home_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/game.tscn")
