extends Node # Autoloads typically extend Node

const SAVE_PATH = "user://save_game.cfg"

var current_coins = 0
var current_day = 1
var current_level = 1
var has_save_game = false # Keep track of save status globally

func _ready():
	_load_game_data()
	# Check if a save file exists and update has_save_game based on that
	has_save_game = FileAccess.file_exists(SAVE_PATH)

func _load_game_data():
	var cfg = ConfigFile.new()
	var err = cfg.load(SAVE_PATH)

	if err != OK:
		print("SaveManager: No save file or failed to load:", err)
		# Reset data if loading fails (e.g., no save file exists)
		current_coins = 0
		current_day = 1
		current_level = 1
		has_save_game = false
		return

	# Get values, providing default values if keys don't exist
	current_coins = cfg.get_value("game", "coins", 0)
	current_day = cfg.get_value("game", "day", 1)
	current_level = cfg.get_value("game", "level", 1)
	has_save_game = cfg.get_value("progress", "has_save", false) # Load save status

	print("SaveManager: Loaded game data.")
	print("SaveManager: Coins =", current_coins, ", Day =", current_day, ", Level =", current_level, ", Has Save =", has_save_game)

func save_game_data(coins: int, day: int, level: int):
	var cfg = ConfigFile.new()

	cfg.set_value("progress", "has_save", true)
	cfg.set_value("game", "coins", coins)
	cfg.set_value("game", "day", day)
	cfg.set_value("game", "level", level)

	var err = cfg.save(SAVE_PATH)
	if err != OK:
		print("SaveManager: Error saving game data:", err)
	else:
		print("SaveManager: Game data saved successfully.")
		# Update internal state after successful save
		current_coins = coins
		current_day = day
		current_level = level
		has_save_game = true

func create_new_save():
	var cfg = ConfigFile.new()

	cfg.set_value("progress", "has_save", true)
	cfg.set_value("game", "coins", 4000) # Initial coins
	cfg.set_value("game", "day", 1)     # Initial day
	cfg.set_value("game", "level", 1)   # Initial level

	var err = cfg.save(SAVE_PATH)
	if err != OK:
		print("SaveManager: Error creating new save file:", err)
	else:
		print("SaveManager: New save file created.")
		# Update internal state after creating new save
		current_coins = 4000
		current_day = 1
		current_level = 1
		has_save_game = true

func save_file_exists() -> bool:
	return FileAccess.file_exists(SAVE_PATH)

func delete_save_file():
	if FileAccess.file_exists(SAVE_PATH):
		var dir = DirAccess.open("user://")
		if dir:
			var err = dir.remove("save_game.cfg")
			if err == OK:
				print("SaveManager: Save file deleted successfully.")
				# Reset internal state after deletion
				current_coins = 0
				current_day = 1
				current_level = 1
				has_save_game = false
			else:
				print("SaveManager: Failed to delete save file. Error code:", err)
		else:
			print("SaveManager: Failed to open user directory for deletion.")
	else:
		print("SaveManager: No save file to delete.")

func get_coins() -> int:
	return current_coins

func add_coins(coins: int) -> void:
	current_coins += coins
	save_game_data(current_coins, current_day, current_level)

func get_day() -> int:
	return current_day

func add_day():
	current_day += 1
	print("Its a new day!! Day: ", current_day)
	save_game_data(current_coins, current_day, current_level)

func get_level() -> int:
	return current_level

func get_has_save_game() -> bool:
	return has_save_game
