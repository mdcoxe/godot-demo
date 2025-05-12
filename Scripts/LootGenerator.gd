extends Node
var loot_data : Dictionary = {}

var rarities = ["common", "uncommon", "rare", "epic"]
var rarity_probabilities = {
	"common": .7,
	"uncommon": .2,
	"rare": .08,
	"epic": .02
}
var rarity_modifiers = {
	"common": {"prefixes": 0, "suffixes": 0},
	"uncommon": {"prefixes": 0, "suffixes": 1},
	"rare": {"prefixes": 1, "suffixes": 1},
	"epic": {"prefixes": 1, "suffixes": 1}
}

func _ready():
	_load_loot_data()
	
func _load_loot_data():
	var file = FileAccess.open("res://loot_data.json", FileAccess.READ)
	if file:
		var content = file.get_as_text()
		var parse_results = JSON.parse_string(content)
		if parse_results is Dictionary:
			loot_data = parse_results
			print("Loot data loaded successfully")
		else:
			push_error("Failed to parse loot_data.json: ", parse_results)
		file.close()
	else:
		push_error("Failed to open loot_data.json")

# Function to generate a random loot item
# player_level: influences the scaling of stats
# event_type: can influence the type of item generated (e.g., "enemy", "loot")
func generate_loot(player_level: int, event_type: String) -> Dictionary:
	if loot_data.is_empty():
		push_error("Loot data not loaded!")
		return {}

	var item_type_pool = []
	
	# Determine which item types can drop based on event_type
	match event_type:
		"loot":
			item_type_pool = ["armor", "weapon", "jewelry", "potion"]
		"enemy":
			item_type_pool = ["armor", "weapon", "potion"] # Enemies might drop gear and potions
		"blacksmith":
			item_type_pool = ["armor", "weapon", "jewelry"] # Blacksmith crafts gear
		# Add more event types as needed
		_:
			item_type_pool = ["armor", "weapon", "jewelry", "potion"] # Default to all types

	# Select a random item type from the pool
	if item_type_pool.is_empty():
		push_error("No item types available for event_type: ", event_type)
		return {}

	var chosen_item_type = item_type_pool[randi() % item_type_pool.size()]

	# Get the list of base items for the chosen type
	var base_items = loot_data.get("item_bases", {}).get(chosen_item_type, [])
	if base_items.is_empty():
		push_error("No base items found for type: ", chosen_item_type)
		return {}

	# Select a random base item
	var base_item = base_items[randi() % base_items.size()].duplicate() # Use duplicate to avoid modifying the original data

	# Determine rarity
	var chosen_rarity = _get_random_rarity()

	# Apply prefixes and suffixes
	var applied_prefix = null
	var applied_suffix = null
	var final_name = base_item.name
	var final_value = base_item.base_value
	var final_stats = base_item.base_stats.duplicate() # Duplicate stats dictionary
#
	# Get potential modifiers based on rarity (from the updated dictionary)
	var potential_prefixes = _get_compatible_modifiers(loot_data.get("prefixes", []), base_item.type, chosen_rarity)
	var potential_suffixes = _get_compatible_modifiers(loot_data.get("suffixes", []), base_item.type, chosen_rarity)

	match chosen_rarity:
		"common":
			# Common items get no prefixes or suffixes
			pass # Do nothing, they start with just the base item
		"uncommon":
			# Uncommon items always get a suffix
			if not potential_suffixes.is_empty():
				applied_suffix = potential_suffixes[randi() % potential_suffixes.size()]
				final_name += " " + applied_suffix.name
				final_value *= applied_suffix.value_multiplier
				_apply_stat_modifiers(final_stats, applied_suffix.stat_modifiers, player_level)
		"rare":
			# Rare items get either a prefix or a suffix (randomly)
			if randf() < 0.5 and not potential_prefixes.is_empty(): # 50% chance for prefix
				applied_prefix = potential_prefixes[randi() % potential_prefixes.size()]
				final_name = applied_prefix.name + " " + final_name
				final_value *= applied_prefix.value_multiplier
				_apply_stat_modifiers(final_stats, applied_prefix.stat_modifiers, player_level)
			elif not potential_suffixes.is_empty(): # Otherwise, apply suffix if available
				applied_suffix = potential_suffixes[randi() % potential_suffixes.size()]
				final_name += " " + applied_suffix.name
				final_value *= applied_suffix.value_multiplier
				_apply_stat_modifiers(final_stats, applied_suffix.stat_modifiers, player_level)
		"epic":
			# Epic items always get a prefix AND a suffix
			if not potential_prefixes.is_empty():
				applied_prefix = potential_prefixes[randi() % potential_prefixes.size()]
				final_name = applied_prefix.name + " " + final_name
				final_value *= applied_prefix.value_multiplier
				_apply_stat_modifiers(final_stats, applied_prefix.stat_modifiers, player_level)
			if not potential_suffixes.is_empty(): # Apply suffix regardless of prefix success
				applied_suffix = potential_suffixes[randi() % potential_suffixes.size()]
				final_name += " " + applied_suffix.name
				final_value *= applied_suffix.value_multiplier
				_apply_stat_modifiers(final_stats, applied_suffix.stat_modifiers, player_level)

	# Scale base stats by player level (simple example - this applies AFTER modifiers)
	# You might want to adjust where/how level scaling is applied based on desired progression
	for stat in final_stats.keys():
		# Simple linear scaling: base_stat + (base_stat * player_level * scaling_factor)
		# Adjust scaling_factor for desired progression speed
		var scaling_factor = 0.1 # Example scaling factor
		if typeof(final_stats[stat]) == TYPE_INT or typeof(final_stats[stat]) == TYPE_FLOAT:
			final_stats[stat] = final_stats[stat] + (base_item.base_stats.get(stat, 0) * player_level * scaling_factor)
			# Ensure integer stats remain integers if desired
			if typeof(base_item.base_stats.get(stat, 0)) == TYPE_INT:
				final_stats[stat] = int(final_stats[stat])


	# Construct the final item dictionary
	var generated_item = {
		"id": base_item.id,
		"name": final_name,
		"type": base_item.type,
		"subtype": base_item.subtype,
		"value": int(final_value), # Cast value to integer
		"stats": final_stats,
		"rarity": chosen_rarity,
		"level": player_level,
		"prefix": applied_prefix.name if applied_prefix else "",
		"suffix": applied_suffix.name if applied_suffix else ""
	}

	return generated_item

# Helper function to get a random rarity based on probabilities
func _get_random_rarity() -> String:
	var rand = randf()
	var cumulative_probability = 0.0
	for rarity in rarities:
		cumulative_probability += rarity_probabilities.get(rarity, 0)
		if rand < cumulative_probability:
			return rarity
	return rarities.back() # Fallback to the last rarity

# Helper function to get compatible modifiers (prefixes/suffixes) for an item type and rarity
func _get_compatible_modifiers(modifiers: Array, item_type: String, rarity: String) -> Array:
	var compatible_list = []
	for modifier in modifiers:
		if modifier.rarity == rarity and (modifier.applies_to.has(item_type) or modifier.applies_to.has("all")):
			compatible_list.append(modifier)
	return compatible_list

# Helper function to apply stat modifiers
func _apply_stat_modifiers(stats: Dictionary, modifiers: Dictionary, player_level: int):
	for stat in modifiers.keys():
		if stats.has(stat):
			# Apply multiplier
			if typeof(modifiers[stat]) == TYPE_FLOAT or typeof(modifiers[stat]) == TYPE_INT:
				stats[stat] *= modifiers[stat]
			# Additive modifiers could be handled here too
			# stats[stat] += modifiers[stat] * player_level # Example additive scaling
		else:
			# Add new stats from modifiers if they don't exist
			stats[stat] = modifiers[stat] * player_level # Example: new stats scale with level
