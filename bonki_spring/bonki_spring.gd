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

var input_ready = false

var forest_scene: String = "res://intro/intro.tscn"

@onready var placement_bonkis: Array[Bonki] = [
	bonki1,
	bonki2,
	bonki3,
	bonki4,
	bonki5,
	bonki6,
	bonki7,
]

var intro_sequence_steps: Array[PlayStep] = [
	PlayStep.animation("intro_01_fade_in_and_pan"),
	PlayStep.text("Bonki Spring..."),
	PlayStep.text("The mythical abode of the guardians of the forest—"),
	PlayStep.text("The legendary Bonkis."),
	PlayStep.text("It's clear now—\nthe reason you've been led here."),
	PlayStep.text("The era of the Bonkis has returned!"),
	PlayStep.text("You've been called to reawaken them with the help of {dog}."),
	PlayStep.text("With a keen eye—\nand some patience—"),
	PlayStep.text("Who knows what else you'll unearth?"),
	PlayStep.action(func(): GameState.complete_dig(); GameState.mark_intro_seen(); input_ready = true; print("Intro sequence complete.")),
]

var regular_steps: Array[PlayStep] = [
	PlayStep.animation("01_fade_in"),
	PlayStep.action(func(): input_ready = true; print("Waiting")),
	
	PlayStep.animation("02_01__consider_walk").label_with("CONSIDER_WALK"),
	PlayStep.choice("Take {dog} on a walk?", {
		"Yes": func(): jump_to_label("GO_TO_FOREST"),
		"No": func(): jump_to_label("STAY_HERE"),
	}),

	PlayStep.text("It's so peaceful here.").label_with("STAY_HERE"),
	PlayStep.text("Let's just sit for a moment."),
	PlayStep.animation("02_02__decide_to_stay"),
	PlayStep.action(func(): print("Waiting")),

	PlayStep.text("Come on, {dog}!").label_with("GO_TO_FOREST"),
	PlayStep.animation("02_03__decide_to_walk"),
	PlayStep.action(func(): TransitionManager.go_to_scene_threaded(forest_scene))
]



var current_step_index = 0

func _ready():
	print("ready!")
	

	dialog_overlay.step_finished.connect(_on_step_finished)
	
	cutscene_player.animation_finished.connect(_on_anim_finished)
	
	dialog_overlay.choice_selected.connect(_on_choice_made)

	show_bonkis()

	if (GameState.seen_intro):
		print("Intro seen already")
	else:
		print("Showing intro sequence")
	run_current_step()
	
func _dog_name() -> String:
	return GameState.dog_name
	
func show_bonkis():
	for bonki in placement_bonkis:
		bonki.hide()
	
	if !GameState.seen_intro:
		var params := GameState.pending_dig.appearance
		var placement_bonki = placement_bonkis[randi_range(0, placement_bonkis.size() - 1)]
		placement_bonki.appearance = params
		placement_bonki.show()
		
		return
	
	var free_bonkis_params := GameState.free_bonkis_appearance_parameters
	var free_bonkis_count: int = free_bonkis_params.size() if free_bonkis_params else 0

	print("showing free bonkis:")
	print(free_bonkis_count)
	
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

func get_steps() -> Array[PlayStep]:
	return regular_steps if GameState.seen_intro else intro_sequence_steps

func run_current_step():
	var steps := get_steps()
	if (current_step_index >= steps.size()):
		print("All steps complete.")
		return
	var step := steps[current_step_index]
	print(step)
	
	match step.type:
		PlayStep.StepType.TEXT:
			dialog_overlay.show_text(format_text(step.text_content))
			# We now wait for the 'step_finished' signal from the UI
			
		PlayStep.StepType.ANIMATION:
			dialog_overlay.hide()
			cutscene_player.play(step.anim_name)
			# We now wait for the 'animation_finished' signal from the Player

		PlayStep.StepType.ACTION:
			dialog_overlay.hide()
			if step.action_callback is Callable:
				step.action_callback.call()
			else:
				print("============================================================================")
				print("Error: Action is not callable or a valid method name -> ", step.action_callback)
				print("============================================================================")

		PlayStep.StepType.CHOICE: 
			var options_text: Array[String] = []
			for option_text in step.options:
				options_text.push_back(format_text(option_text))
			dialog_overlay.show_choices(format_text(step.text_content), options_text)

		PlayStep.StepType.TEXT_INPUT:
			print("NOT IMPLEMENTED: TEXT INPUT STEP")
			print(step)

func format_text(text: String):
	return text.format({"dog": GameState.dog_name})

func _on_step_finished():
	print("_on_step_finished")
	# Called when text is dismissed
	current_step_index += 1
	run_current_step()

func _on_anim_finished(anim_name):
	# Called when an animation finishes
	current_step_index += 1

	run_current_step()
	
func jump_to_label(target_label: String):
	print("jumping to")
	print(target_label)
	var target = get_step_index_by_label(target_label)
	if (target == null):
		print("Not moving step ", target_label)
	else:
		current_step_index = target
		run_current_step()



func get_step_index_by_label(target_label: String):
	var steps := get_steps()
	for i in range(steps.size()):
		var step = steps[i]
		if step.label == target_label:
			return  i
	print("Error: Label not found -> ", target_label)

func _on_choice_made(index: int):
	var steps := get_steps()
	var step: = steps[current_step_index]
	var actions = step.options.values()
	var action = actions[index]
	
	# Hide the choices immediately
	dialog_overlay.choice_container.hide()

	action.call()



func _on_character_body_3d_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if !input_ready:
		return
	# Check if the event is a mouse button click or a screen touch
	if event is InputEventMouseButton:
		print("dog tapped!")
		# Check if it's the left mouse button and it was just pressed (not released)
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			print("dog tapped!!!!")
			jump_to_label("CONSIDER_WALK")
