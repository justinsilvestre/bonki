extends Node

# The file path where data is saved. 
# "user://" maps to AppData (Windows) or Documents (Mobile), safe for writing.
const SAVE_PATH = "user://savegame.json"

# GLOBAL VARIABLES
var dog_name: String = "Doggo" # Default
var seen_intro: bool = false
var free_bonkis_appearance_parameters: Array = []
var pending_dig: PendingDig

func _ready():
	load_game()
	print("save data loaded from")
	print(ProjectSettings.globalize_path(SAVE_PATH))
	print({
		"seen_intro": seen_intro,
		"dog_name": dog_name,
		"free_bonkis_appearance_parameters": free_bonkis_appearance_parameters.map(
			func(p: BonkiAppearanceParameters) -> Dictionary: return p.toJSON()
			) if free_bonkis_appearance_parameters else [],
		"pending_dig": pending_dig.toJSON() if pending_dig else null
	})

func save_game():
	# 1. Gather all data into a dictionary
	var data = {
		"seen_intro": seen_intro, 
		"dog_name": dog_name,
		"free_bonkis_appearance_parameters": free_bonkis_appearance_parameters.map(func(p: BonkiAppearanceParameters): return p.toJSON()),
		"pending_dig": pending_dig.toJSON() if pending_dig else null
	}
	
	print("Saving...")
	
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
		
		free_bonkis_appearance_parameters = []
		
		if data:
			#data["pending_dig"] = {"appearance":{"body_color":"98820dff","crown_id":"yellow_stagshorn","eye_base_color":"6ba3aeff","eye_shadow_color":"82263bff","eye_shine_color":"9ed7e3ff","eyes_height_factor":-0.557908557648342,"eyes_spread_factor":-0.824235819896912,"eyes_tilt_factor":0.398674684889073,"horn_stretch_factor":0.305776306489096,"long_stretch_factor":0.83278493178736,"pearness_factor":0.89741159736779,"tall_stretch_factor":-0.355586347488911,"wide_stretch_factor":0.659000761892685,"wonkiness_factor":0.125632307277865},"duration_seconds":15,"start_unix_time":1770494441.0}
			# 3. Restore variables safely
			if "dog_name" in data:
				dog_name = data["dog_name"]
			if "seen_intro" in data:
				seen_intro = data["seen_intro"]
			if "free_bonkis_appearance_parameters" in data and data["free_bonkis_appearance_parameters"]:
				free_bonkis_appearance_parameters = data["free_bonkis_appearance_parameters"].map(
					func(j: Dictionary) -> BonkiAppearanceParameters: return BonkiAppearanceParameters.fromJSON(j)
				)
			if "pending_dig" in data and data["pending_dig"]:
				pending_dig = PendingDig.fromJSON(data["pending_dig"])
		else:
			print("Error: Corrupted save file.")



func mark_intro_seen() -> void:
	seen_intro = true
	save_game()
	
func add_bonki(appearance: BonkiAppearanceParameters) -> void:
	free_bonkis_appearance_parameters.push_back(appearance)
	save_game()

func save_dog_name(name: String):
	dog_name = name
	save_game()
	
func start_dig(
	start_unix_time: int,
	duration_seconds: int,
	pending_dig_appearance: BonkiAppearanceParameters
):
	pending_dig = PendingDig.create(
		start_unix_time,
		duration_seconds,
		pending_dig_appearance
	)
	save_game()
	print("Saved pending dig")
	print(pending_dig)

func interrupt_dig():
	pending_dig = null
	save_game()

func complete_dig():
	if (!pending_dig):
		print("COMPLETE DIG CALLED WHEN NO PENDING DIG")
		return
	free_bonkis_appearance_parameters.push_back(pending_dig.appearance)
	pending_dig = null
	save_game()
