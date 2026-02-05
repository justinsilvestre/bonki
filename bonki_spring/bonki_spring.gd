extends Node

signal step_finished

@onready var cutscene_player = $AnimationPlayer
@onready var dialog_overlay := $UI_CanvasLayer/Overlay_Control
@onready var music_player : AudioStreamPlayer = $AudioStreamPlayer
@onready var bonki: Bonki = $SubViewportContainer/SubViewport/World_Node3D/Bonki

var intro_sequence_steps = [
	# transition to Bonki Spring
	{"type": "anim", "anim_name": "intro_01_fade_in_and_pan"},
	# pan around
	{"type": "anim", "anim_name": "RESET"},
	{"type": "text", "content": "Bonki Spring..."},
	{"type": "text", "content": "The mythical abode of the guardians of the forest—"},
	{"type": "text", "content": "The legendary Bonkis."},
	{"type": "text", "content": "It's clear now—\nthe reason you've been led here."},
	{"type": "text", "content": "The era of the Bonkis has returned!"},
	{"type": "text", "content": "You've been called to reawaken them with the help of DOG."},
	{"type": "text", "content": "Onward!"},
	{"type": "text", "content": "With a keen eye—\nand some patience—"},
	{"type": "text", "content": "Perhaps you'll unearth something even more incredible."},
]

var normal_steps = [
	{"type": "anim", "anim_name": "fade_in"},
	
]

var current_step_index = 0

func _ready():
	# Connect the UI signal to our advance function
	dialog_overlay.step_finished.connect(_on_step_finished)
	
	# Connect the AnimationPlayer signal to our advance function
	cutscene_player.animation_finished.connect(_on_anim_finished)

	if (GameState.seen_intro):
		print("Intro seen already")
	else:
		print("Showing intro sequence")
	start_step()
	
func _dog_name() -> String:
	return GameState.dog_name

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
	
	sfx_player.volume_db = 0 # Reset volume in case it was faded out
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
		
