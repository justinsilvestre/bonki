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

#var test_state = { "seen_intro": true, "dog_name": "Doggo", "free_bonkis_appearance_parameters": [{ "body_color": "855632ff", "eye_shine_color": "b9d6b1ff", "eye_shadow_color": "1d603cff", "eye_base_color": "689d56ff", "wide_stretch_factor": 0.96986627408082, "horn_stretch_factor": 0.36613464708097, "long_stretch_factor": -0.24715921146159, "pearness_factor": -0.6480019943898, "tall_stretch_factor": 0.51673992517112, "wonkiness_factor": -0.31363568210281, "eyes_spread_factor": -0.38642032470486, "eyes_tilt_factor": 0.93801978731272, "eyes_height_factor": 0.89790576103819, "crown_id": "enoki" }, { "body_color": "af8c57ff", "eye_shine_color": "d4eed5ff", "eye_shadow_color": "ce96f6ff", "eye_base_color": "73a677ff", "wide_stretch_factor": 0.2841162789845, "horn_stretch_factor": 0.25101956792614, "long_stretch_factor": 0.23388293554417, "pearness_factor": -0.36143142829773, "tall_stretch_factor": 0.59196497439909, "wonkiness_factor": -0.73886209347709, "eyes_spread_factor": 0.91650356472842, "eyes_tilt_factor": 0.26172049335123, "eyes_height_factor": 0.37612927013752, "crown_id": "porcini" }, { "body_color": "40603cff", "eye_shine_color": "e5f5ebff", "eye_shadow_color": "32a896ff", "eye_base_color": "59ae81ff", "wide_stretch_factor": 0.01484007472467, "horn_stretch_factor": 0.34859977410829, "long_stretch_factor": -0.64328656177864, "pearness_factor": 0.11584522641915, "tall_stretch_factor": -0.75726080902289, "wonkiness_factor": -0.41008354684059, "eyes_spread_factor": -0.3194228962706, "eyes_tilt_factor": 0.31913957195642, "eyes_height_factor": -0.62459955510012, "crown_id": "kale" }, { "body_color": "87c8daff", "eye_shine_color": "bdd3ecff", "eye_shadow_color": "841f3eff", "eye_base_color": "557192ff", "wide_stretch_factor": -0.76633364237954, "horn_stretch_factor": 0.28795677122523, "long_stretch_factor": 0.31447855586054, "pearness_factor": -0.40745234887492, "tall_stretch_factor": 0.14509432841988, "wonkiness_factor": 0.63498382806376, "eyes_spread_factor": -0.60562373265745, "eyes_tilt_factor": -0.12400405279, "eyes_height_factor": 0.98439601605042, "crown_id": "christmas_rose" }, { "body_color": "7ca765ff", "eye_shine_color": "daefeeff", "eye_shadow_color": "38add1ff", "eye_base_color": "609190ff", "wide_stretch_factor": 0.02379743495593, "horn_stretch_factor": 0.17825654930239, "long_stretch_factor": 0.44061765301527, "pearness_factor": 0.60775912006209, "tall_stretch_factor": 0.0714154676516, "wonkiness_factor": 0.17307982070951, "eyes_spread_factor": 0.26154447996413, "eyes_tilt_factor": -0.01249663937155, "eyes_height_factor": -0.21221714330582, "crown_id": "pincushion_moss" }, { "body_color": "927a10ff", "eye_shine_color": "acd3c6ff", "eye_shadow_color": "b32f9bff", "eye_base_color": "6b9588ff", "wide_stretch_factor": -0.84237765733674, "horn_stretch_factor": 0.18730983690933, "long_stretch_factor": 0.30810101377175, "pearness_factor": 0.08665294604955, "tall_stretch_factor": -0.25898059216128, "wonkiness_factor": -0.92824184918494, "eyes_spread_factor": 0.96951233824631, "eyes_tilt_factor": 0.46561026705193, "eyes_height_factor": 0.2136630048433, "crown_id": "yellow_stagshorn" }, { "body_color": "3f5e3cff", "eye_shine_color": "dbe9f2ff", "eye_shadow_color": "72aafdff", "eye_base_color": "64aaceff", "wide_stretch_factor": 0.47193060427013, "horn_stretch_factor": 0.0672767495972, "long_stretch_factor": -0.20803146094687, "pearness_factor": 0.65792775229882, "tall_stretch_factor": -0.86006511005174, "wonkiness_factor": -0.83147547412995, "eyes_spread_factor": 0.51923764525478, "eyes_tilt_factor": 0.7785683338543, "eyes_height_factor": 0.33797164855065, "crown_id": "kale" }, { "body_color": "3f5e3cff", "eye_shine_color": "dbe9f2ff", "eye_shadow_color": "72aafdff", "eye_base_color": "64aaceff", "wide_stretch_factor": 0.47193060427013, "horn_stretch_factor": 0.0672767495972, "long_stretch_factor": -0.20803146094687, "pearness_factor": 0.65792775229882, "tall_stretch_factor": -0.86006511005174, "wonkiness_factor": -0.83147547412995, "eyes_spread_factor": 0.51923764525478, "eyes_tilt_factor": 0.7785683338543, "eyes_height_factor": 0.33797164855065, "crown_id": "kale" }, { "body_color": "629a73ff", "eye_shine_color": "f8f8fdff", "eye_shadow_color": "674817ff", "eye_base_color": "8179dbff", "wide_stretch_factor": 0.51525881313443, "horn_stretch_factor": 0.38133321563098, "long_stretch_factor": 0.59678423224773, "pearness_factor": 0.42363973693618, "tall_stretch_factor": -0.27493907182948, "wonkiness_factor": 0.97693513238226, "eyes_spread_factor": -0.88450915221079, "eyes_tilt_factor": -0.63448577426203, "eyes_height_factor": 0.96050517789559, "crown_id": "cladonia" }], "pending_dig": <null> }
