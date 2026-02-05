extends Node

# The file path where data is saved. 
# "user://" maps to AppData (Windows) or Documents (Mobile), safe for writing.
const SAVE_PATH = "user://savegame.json"

# GLOBAL VARIABLES
var dog_name: String = "Doggo" # Default
var seen_intro: bool = false
var free_bonkis_appearance_parameters: Array[BonkiAppearanceParameters] = []

func _ready():
	load_game()

func save_game():
	# 1. Gather all data into a dictionary
	var data = {
		"seen_intro": seen_intro,
		"dog_name": dog_name,
		"free_bonkis_appearance_parameters": JSON.from_native(free_bonkis_appearance_parameters),
	}
	
	# 2. Open file for writing
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		# 3. Store as JSON string
		var json_string = JSON.stringify(data)
		file.store_string(json_string)
		print("Game Saved: ", json_string)
	else:
		print("Error: Could not save game.")

func load_game():
	# 1. Check if file exists
	if not FileAccess.file_exists(SAVE_PATH):
		print("No save file found. Using defaults.")
		return # Keep default "Doggo"

	# 2. Open file for reading
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file:
		var content = file.get_as_text()
		var data = JSON.parse_string(content)
		
		if data:
			# 3. Restore variables safely
			if "dog_name" in data:
				dog_name = data["dog_name"]
			if "seen_intro" in data:
				seen_intro = data["seen_intro"]
			if "free_bonkis_appearance_parameters" in data:
				free_bonkis_appearance_parameters = JSON.to_native(data["free_bonkis_appearance_parameters"])
		else:
			print("Error: Corrupted save file.")



func mark_intro_seen() -> void:
	seen_intro = true
	save_game()
	
func add_bonki(appearance: BonkiAppearanceParameters) -> void:
	free_bonkis_appearance_parameters.push_back(appearance)

func save_dog_name(name: String):
	dog_name = name
	save_game()
