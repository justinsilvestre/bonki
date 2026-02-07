extends Node

signal step_finished

@onready var cutscene_player = $AnimationPlayer
@onready var dialog_overlay := $UI_CanvasLayer/Overlay_Control
@onready var music_player : AudioStreamPlayer = $Music_AudioStreamPlayer


@onready var bonki1 := $SubViewportContainer/SubViewport/WorldNode3D/Bonki1
@onready var bonki2 := $SubViewportContainer/SubViewport/WorldNode3D/Bonki2
@onready var bonki3 := $SubViewportContainer/SubViewport/WorldNode3D/Bonki3
@onready var bonki4 := $SubViewportContainer/SubViewport/WorldNode3D/Bonki4
@onready var bonki5 := $SubViewportContainer/SubViewport/WorldNode3D/Bonki5
@onready var bonki6 := $SubViewportContainer/SubViewport/WorldNode3D/Bonki6
@onready var bonki7 := $SubViewportContainer/SubViewport/WorldNode3D/Bonki7

@onready var placement_bonkis: Array[Bonki] = [
	bonki1,
	bonki2,
	bonki3,
	bonki4,
	bonki5,
	bonki6,
	bonki7,
]

var intro_sequence_steps = [
	{"type": "anim", "anim_name": "intro_01_fade_in_and_pan"},
	{"type": "text", "content": "Bonki Spring..."},
	{"type": "text", "content": "The mythical abode of the guardians of the forest—"},
	{"type": "text", "content": "The legendary Bonkis."},
	{"type": "text", "content": "It's clear now—\nthe reason you've been led here."},
	{"type": "text", "content": "The era of the Bonkis has returned!"},
	{"type": "text", "content": "You've been called to reawaken them with the help of DOG."},
	{"type": "text", "content": "With a keen eye—\nand some patience—"},
	{"type": "text", "content": "Who knows what else you'll unearth?"},
]

var normal_steps = [
	{"type": "anim", "anim_name": "fade_in"},
]

var current_step_index = 0



func _ready():
	print("ready!")
	# Connect the UI signal to our advance function
	dialog_overlay.step_finished.connect(_on_step_finished)
	
	# Connect the AnimationPlayer signal to our advance function
	cutscene_player.animation_finished.connect(_on_anim_finished)
	
	show_bonkis()

	if (GameState.seen_intro):
		print("Intro seen already")
	else:
		print("Showing intro sequence")
	start_step()
	
func _dog_name() -> String:
	return GameState.dog_name
	
func show_bonkis():
	var free_bonkis_params := GameState.free_bonkis_appearance_parameters
	var free_bonkis_count: int = free_bonkis_params.size() if free_bonkis_params else 0
	for bonki in placement_bonkis:
		bonki.hide()
	
	var present_bonkis_count: int = min(free_bonkis_count, placement_bonkis.size())
	var present_bonki_placements := get_random_elements(placement_bonkis, present_bonkis_count)
	var present_bonki_params := get_random_elements(free_bonkis_params, present_bonkis_count)
	
	for i in present_bonkis_count:
		var placement = present_bonki_placements[i]
		var appearance = present_bonki_params[i]
		placement.appearance = appearance
		placement.show()

## Returns N unique random elements from the source array.
func get_random_elements(source_array: Array, n: int) -> Array:
	# 1. Create a shallow copy so we don't mess up the original list
	var pool = source_array.duplicate()
	
	# 2. Randomize the order of the copy
	pool.shuffle()
	
	# 3. Clamp N to ensure we don't try to grab more than exists
	var count = min(n, pool.size())
	
	# 4. Return the first 'count' elements
	return pool.slice(0, count)

func start_step():
	var steps = intro_sequence_steps if GameState.seen_intro else normal_steps
	if current_step_index >= intro_sequence_steps.size():
		print("INTRO SEQUENCE FINISHED")
		#GameState.mark_intro_seen()
		#TransitionManager.go_to_scene_threaded(NEXT_SCENE)
		return

	var step = intro_sequence_steps[current_step_index]
	print(step)
	
	if step["type"] == "text":
		dialog_overlay.show_text(step["content"].replace("DOG", _dog_name()))
		# We now wait for the 'step_finished' signal from the UI
		
	elif step["type"] == "anim":
		dialog_overlay.hide()
		cutscene_player.play(step["anim_name"])
		# We now wait for the 'animation_finished' signal from the Player

	elif step["type"] == "spec":
		## Example: call a function dynamically based on the action name
		if has_method(step["action"]):
			call(step["action"])
		_on_step_finished()

	elif step["type"] == "choice": 
		dialog_overlay.show_choices(step["content"], step["options"])

	elif step["type"] == "text_input":
		var default = step.get("default", _dog_name()) 
		dialog_overlay.show_text_input(step["content"], default)


func _on_step_finished():
	# Called when text is dismissed
	current_step_index += 1
	start_step()

func _on_anim_finished(anim_name):
	# Called when an animation finishes
	current_step_index += 1
	
	#sfx_player.volume_db = 0 # Reset volume in case it was faded out
	start_step()
	
func jump_to_label(target_label: String):
	var steps = intro_sequence_steps if GameState.seen_intro else normal_steps
	for i in range(steps.size()):
		var step = steps[i]
		if step.has("label") and step["label"] == target_label:
			current_step_index = i
			start_step()
			return
	print("Error: Label not found -> ", target_label)
	

func start():
	var bg_music = load("res://sound/garden-music_last_3m30s.mp3")
	
	if bg_music:
		music_player.stream = bg_music
		music_player.volume_db = 0 # Reset volume in case it was faded out
		music_player.play()
