extends Control

signal step_finished

@onready var cutscene_player = $AnimationPlayer
@onready var dialog_overlay := $UI_CanvasLayer/Overlay_Control
@onready var loop_player : AudioStreamPlayer = $AudioStreamPlayer
@onready var music_player: AudioStreamPlayer = $Music_AudioStreamPlayer
@onready var sfx_player: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var bonki: Bonki = $SubViewportContainer/SubViewport/World_Node3D/Bonki
@onready var dog := $SubViewportContainer/SubViewport/World_Node3D/DogModel

@onready var dig_meter = $UI_CanvasLayer/DigMeter

@onready var dog_name := GameState.dog_name


# we don't want to trigger the final bonki reveal until e.g. any text prompts are complete
var ready_for_dig_complete := false
var pending_dig: PendingDig = null

const INTRO_DIG_SECONDS = 30
const DEFAULT_DIG_SECONDS = 300 # 5 minutes
#const DEFAULT_DIG_SECONDS = 5 # 5 seconds

const NEXT_SCENE = "res://bonki_spring/bonki_spring.tscn"

var sound_paths := {
	"footsteps": "res://sound/sfx/pixabay_footsteps-dirt-gravel.mp3"
}

var intro_sequence_steps : Array[PlayStep] = [
	PlayStep.animation("1_01__start"),
	PlayStep.action(func(): start_music(); start_looping_sound("footsteps"); _on_step_finished()),
	#PlayStep.action(func(): scan_music_after_unearthing()),
	# start BG music, start footsteps sound
	PlayStep.text("The air is thick with the soothing fragrance of pine."),
	PlayStep.text("It almost makes you forget just how long you've been lost in Bonki Forest."),
	PlayStep.text("You haven't seen another soul in at least..."),
	PlayStep.action(func(): stop_looping_sound(0.3); _on_step_finished()),
	PlayStep.text("How long has it been, again?"),
	# sound of dog running behind you left to right
	PlayStep.animation("1_02__dog_runs_behind"),
	# footsteps stop, black fades to reveal empty scene
	PlayStep.text("What was that?"),
	# sound of dog running behind you right to left to right
	PlayStep.animation("1_03__dog_runs"),
	PlayStep.text("Who's there?"),
	# dog appears on scene, camera pans to reveal dog with wagging tail
	PlayStep.animation("1_04__dog_appears"),
	
	PlayStep.text("Would you look at that!"),
	PlayStep.text("You're not alone in these woods after all."),
	# dog greets you
	PlayStep.animation("1_05__dog_greets"),
	PlayStep.text_input("What shall we call you?"),
	PlayStep.text("Yes, they're definitely a {dog}."),
	# dog barks a couple times.
	PlayStep.animation("1_06__dog_barks"),
	PlayStep.text("Easy now, {dog}!"),
	# dog barks a couple times more.
	PlayStep.animation("1_07__dog_barks"), 
	PlayStep.text("What's the matter?"),
	# dog runs off screen
	PlayStep.animation("1_08__dog_runs_off"),
	PlayStep.text("Maybe {dog} knows the way out!"), 
	PlayStep.text("Quickly, now!"),
	# camera pans in dog's direction + fades to black.
	PlayStep.animation("1_09__follow_dog"),
	# random bonki crown now sticks out of ground next to dog, now in center of ground surface
	PlayStep.action(
		func(): refresh_bonki(); _on_step_finished()
	),
	# you catch up to the dog, i.e. camera jumps to opposite edge of screen, pans in same direction as last pan as screen fades from black
	PlayStep.animation("1_10__catch_up_to_dog"),
	PlayStep.text("This isn't the way out..."),
	PlayStep.text("Why did {dog} bring you here?"),
	PlayStep.text("Wait."),
	PlayStep.text("What's that?"),
	# camera pans down towards bonki crown sticking out of ground
	PlayStep.animation("1_11__notice_bonki"),
	PlayStep.text("You've never seen anything like it."),
	PlayStep.text("And yet..."),
	PlayStep.text("It feels familiar."),
	
	# prompt yes/no
	PlayStep.choice("What will you do?", {
		"Keep a respectful distance.": func(): jump_to_label("DOG_STARTS_DIGGING"),
		"Yank it out!": func(): jump_to_label("TRY_PICKING"),
	}),
	# if yes (pick it), camera lowers and dog barks
	# if no (don't pick it), dog starts digging
	# camera lowers toward bonki, dog barks and camera moves back fast
	PlayStep.animation("2_01__dog_warns").label_with("TRY_PICKING"),
	PlayStep.text("Oh, {dog} didn't like that..."),
	PlayStep.choice("What shall you do?", {
		"Wait here a bit": func(): jump_to_label("DOG_STARTS_DIGGING"),
		"Move left": func(): jump_to_label("REFRESH_BONKI_TO_LEFT"),
		"Move right": func(): jump_to_label("REFRESH_BONKI_TO_RIGHT"),
	}),
	
	# if 'wait here a bit', dog starts digging
	# if move left or right, refresh bonki
	PlayStep.animation("3_001_follow_dog_to_left").label_with("REFRESH_BONKI_TO_LEFT"),
	PlayStep.action(func(): refresh_bonki(); _on_step_finished()
	),
	
	# camera jumps to opposite edge of screen, pans in same direction as last pan while screen fades from black
	PlayStep.animation("3_01__catch_up_to_dog_to_left"),
	PlayStep.text("This isn't the way out..."),
	PlayStep.animation("1_11__notice_bonki"),
	PlayStep.text("What's that?"),
	PlayStep.text("It feels familiar."),
	PlayStep.choice("What will you do?", {
		"Let it grow in peace.": func(): jump_to_label("DOG_STARTS_DIGGING"),
		"Yank it out!": func(): jump_to_label("TRY_PICKING"),
	}),
	PlayStep.animation("3_002_follow_dog_to_right").label_with("REFRESH_BONKI_TO_RIGHT"),
	PlayStep.action(func(): refresh_bonki(); _on_step_finished()
	),
	# camera jumps to opposite edge of screen, pans in same direction as last pan while screen fades from black
	PlayStep.animation("3_02__catch_up_to_dog_to_right"),
	PlayStep.text("This isn't the way out..."),
	PlayStep.animation("1_11__notice_bonki"),
	PlayStep.text("What's that?"),
	PlayStep.text("It feels familiar."),
	PlayStep.choice("What will you do?", {
  	"Observe it in silence.": func(): jump_to_label("DOG_STARTS_DIGGING"),
		"Yank it out!": func(): jump_to_label("TRY_PICKING"),
	}),
	
	# dog starts digging
	PlayStep.animation("4_01__dog_starts_digging").label_with("DOG_STARTS_DIGGING"),
	PlayStep.action(func(): start_dig_timer(); _on_step_finished()),
	PlayStep.text("{dog} seems to be enjoying themself.").label_with("CONSIDER_GOING"),
	PlayStep.text("But perhaps we should keep searching for the way out..."),
	# dog keeps digging, meter starts
	# prompt yes/no
	PlayStep.choice("What will you do?", {
		"Wait and see what\n{dog} digs up.": func(): jump_to_label("LET_METER_RUN"),
		"Chop chop! Gotta go!": func(): jump_to_label("CALL_DOG"),
	}),
	# if yes (get going), call {dog}
	# if no, wait until dog finished digging
	
	# when reopening game
	PlayStep.animation("4_02__dog_continues_digging").label_with("DOG_CONTINUES_DIGGING"),
	PlayStep.action(func(): let_meter_run()).label_with("LET_METER_RUN"),
	
	
	# call {dog}
	PlayStep.action(func(): interrupt_dig(); _on_step_finished()).label_with("CALL_DOG"),
	PlayStep.text("Here, {dog}!"),
	PlayStep.animation("5_01__dog_stops_digging"),
	PlayStep.choice("What shall you do?", {
		"Wait here a bit": func(): jump_to_label("DOG_STARTS_DIGGING"),
		"Move left": func(): jump_to_label("REFRESH_BONKI_TO_LEFT"),
		"Move right": func(): jump_to_label("REFRESH_BONKI_TO_RIGHT"),
	}),
	# prompt go left/wait here a bit/go right — SAME AS ABOVE
	
	# wait until dog finished digging
	PlayStep.animation("6_01__dog_finishes_digging").label_with("DOG_FINISHES_DIGGING"),
	# bonki is unearthed
	PlayStep.animation("6_02__bonki_is_unearthed"),
	PlayStep.text("What on Earth?"),
	# bonki runs away, dog runs after
	PlayStep.animation("6_03__they_run_off"),
	PlayStep.text("There's no way..."),
	# dog barks
	PlayStep.animation("6_04__bark_in_distance"),
	PlayStep.text("Wait up!"),
	# camera pans fast, black, running footsteps sound starts
	PlayStep.animation("6_05__fade_to_black"),
	PlayStep.text("Were the stories all true?"),
	PlayStep.text("Even if they were, no one's reported a sighting in ages..."),
	PlayStep.text("..."),
	PlayStep.text("But still..."),
	PlayStep.text("You've got to make sure."),
	PlayStep.text("You can't let it get away!"),
	PlayStep.text("Run, {dog}!"),
	PlayStep.text("Follow that creature!"),
	PlayStep.action(func(): next_scene())
]

var regular_steps: Array[PlayStep] = [
	PlayStep.animation("REG_1_01__start"),
	PlayStep.action(func(): start_music(); _on_step_finished()),
	PlayStep.text("It's biting cold in Bonki Forest today."),
	PlayStep.text("But {dog} doesn't seem to mind."),
	PlayStep.choice("Which way will you go?", {
		"Left": func(): jump_to_label("FOLLOW_DOG_TO_LEFT_BEFORE_ENCOUNTER"),
		"Right": func(): jump_to_label("FOLLOW_DOG_TO_RIGHT_BEFORE_ENCOUNTER"),
	}),

	PlayStep.animation("REG_2_01__follow_dog_to_left_before_encounter").label_with("FOLLOW_DOG_TO_LEFT_BEFORE_ENCOUNTER"),
	PlayStep.action(func(): jump_to_label("REFRESH_BONKI_TO_LEFT")),
	PlayStep.animation("REG_2_02__follow_dog_to_right_before_encounter").label_with("FOLLOW_DOG_TO_RIGHT_BEFORE_ENCOUNTER"),
	PlayStep.action(func(): jump_to_label("REFRESH_BONKI_TO_RIGHT")),

	PlayStep.animation("3_001_follow_dog_to_left").label_with("FOLLOW_DOG_TO_LEFT_AFTER_ENCOUNTER"),
	PlayStep.action(func(): refresh_bonki(); _on_step_finished()).label_with("REFRESH_BONKI_TO_LEFT"),
	PlayStep.animation("3_01__catch_up_to_dog_to_left"),
	PlayStep.animation("1_11__notice_bonki"),
	PlayStep.text("What's that?"),
	PlayStep.text("It feels familiar."),
	PlayStep.choice("What will you do?", {
		"Let {dog} at it": func(): jump_to_label("DOG_STARTS_DIGGING"),
		"Move left": func(): jump_to_label("FOLLOW_DOG_TO_LEFT_AFTER_ENCOUNTER"),
		"Move right": func(): jump_to_label("FOLLOW_DOG_TO_RIGHT_AFTER_ENCOUNTER"),
	}),
	PlayStep.animation("3_002_follow_dog_to_right").label_with("FOLLOW_DOG_TO_RIGHT_AFTER_ENCOUNTER"),
	PlayStep.action(func(): refresh_bonki(); _on_step_finished()).label_with("REFRESH_BONKI_TO_RIGHT"),
	PlayStep.animation("3_02__catch_up_to_dog_to_right"),
	PlayStep.animation("1_11__notice_bonki"),
	PlayStep.text("What's that?"),
	PlayStep.text("It feels familiar."),
	PlayStep.choice("What will you do?", {
		"Let {dog} at it": func(): jump_to_label("DOG_STARTS_DIGGING"),
		"Move left": func(): jump_to_label("FOLLOW_DOG_TO_LEFT_AFTER_ENCOUNTER"),
		"Move right": func(): jump_to_label("FOLLOW_DOG_TO_RIGHT_AFTER_ENCOUNTER"),
	}),

	PlayStep.animation("4_01__dog_starts_digging").label_with("DOG_STARTS_DIGGING"),
	PlayStep.action(func(): start_dig_timer(); _on_step_finished()),
	PlayStep.text("{dog} seems to be enjoying themself.").label_with("CONSIDER_GOING"),
	PlayStep.text("But perhaps there's more exploring to do..."),
	# dog keeps digging, meter starts
	# prompt yes/no
	PlayStep.choice("What will you do?", {
		"Wait and see what\n{dog} digs up.": func(): jump_to_label("LET_METER_RUN"),
		"Chop chop! Gotta go!": func(): jump_to_label("CALL_DOG"),
	}),

	PlayStep.animation("4_02__dog_continues_digging").label_with("DOG_CONTINUES_DIGGING"),
	PlayStep.action(func(): let_meter_run()).label_with("LET_METER_RUN"),

	PlayStep.action(func(): interrupt_dig(); _on_step_finished()).label_with("CALL_DOG"),
	PlayStep.text("Here, {dog}!"),
	PlayStep.animation("5_01__dog_stops_digging"),
	PlayStep.choice("What shall you do?", {
		"Wait here a bit": func(): jump_to_label("DOG_STARTS_DIGGING"),
		"Move left": func(): jump_to_label("REFRESH_BONKI_TO_LEFT"),
		"Move right": func(): jump_to_label("REFRESH_BONKI_TO_RIGHT"),
	}),

	PlayStep.animation("6_01__dog_finishes_digging").label_with("DOG_FINISHES_DIGGING"),
	PlayStep.animation("6_02__bonki_is_unearthed"),
	PlayStep.text("You've freed another Bonki!"),
	PlayStep.text("Good dog, {dog}!"),
	PlayStep.text("Let's bring our new friend home to Bonki Spring."),
	PlayStep.animation("REG_6_01__fade_out"),
	PlayStep.action(func(): next_scene())
	
]

var current_step_index = 0

func _ready():
	bonki.hide_eyes()
	if (GameState.pending_dig):
		print("Resuming pending dig!")
		current_step_index = get_step_index_by_label("DOG_CONTINUES_DIGGING")
		dog.show()
		print("setting bonki appearance")
		print(GameState.pending_dig.appearance)
		bonki.appearance = GameState.pending_dig.appearance
		bonki.show()
	else:
		dig_meter.hide()
	print("Starting at step")
	print(current_step_index)
	
	print("GameState.dog_name")
	print(GameState.dog_name)
	
	#dig_timer

	dialog_overlay.step_finished.connect(_on_step_finished)
	
	cutscene_player.animation_finished.connect(_on_anim_finished)
	
	dialog_overlay.choice_selected.connect(_on_choice_made)
	
	dialog_overlay.text_submitted.connect(_on_text_submitted)
	
	
	# Start the sequence
	run_current_step()
	
var complete_dig_sequence_ongoing := false

func _process(_delta):
	if GameState.pending_dig and !complete_dig_sequence_ongoing:
		var now = Time.get_unix_time_from_system()
		var remaining = (GameState.pending_dig.complete_time()) - now
		
		var progress = remaining / GameState.pending_dig.duration_seconds
		dig_meter.value = clamp(progress * 100, 0, 100)
		
		# Check for completion
		if now >= GameState.pending_dig.complete_time():
			complete_dig_sequence_ongoing = true
			complete_dig()

func format_text(text: String):
	return text.format({"dog": dog_name})

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
			dialog_overlay.show_text_input(format_text(step.text_content), dog_name)


func _on_step_finished():
	print("_on_step_finished")
	# Called when text is dismissed
	current_step_index += 1
	run_current_step()

func _on_anim_finished(anim_name):
	# Called when an animation finishes
	current_step_index += 1
	
	sfx_player.volume_db = 0 # Reset volume in case it was faded out
	run_current_step()
	
func jump_to_label(target_label: String):
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
	print("options")
	print(actions)
	print("option index")
	print(index)
	
	# Hide the choices immediately
	dialog_overlay.choice_container.hide()

	action.call()

func _on_text_submitted(new_text: String):
	# Save the name!
	dog_name = new_text
	GameState.save_dog_name(dog_name)
	print("Name saved: ", dog_name)
	
	# Move to next step
	current_step_index += 1
	run_current_step()

func start_music():
# called in start animation step
	var bg_music = load("res://sound/kami-no-koe.mp3")
	
	if bg_music:
		music_player.stream = bg_music
		bg_music.loop = true
		music_player.volume_db = 0 
		music_player.play()

func scan_music_after_unearthing():
	if (music_player.stream):
		music_player.play(36)
	
func fade_out_music(duration: float = 0.5):
	# Create a tween local to this function
	var tween = create_tween()
	
	# Transition the volume_db property to -80 (silent) over the duration
	tween.tween_property(music_player, "volume_db", -80.0, duration)
	
	# Optional: Completely stop the player once the fade is finished
	tween.finished.connect(func():
		music_player.stop()
		music_player.volume_db = 0
	)

func refresh_bonki():
	print("Bonki refreshed!")
	print(bonki)
	var new_appearance = BonkiAppearanceParameters.new()
	new_appearance.randomize()
	bonki.appearance = 	new_appearance
	bonki.hide_eyes()


## Starts a looping sound. 
## 'path' is the string path to your sound file (e.g., "res://sounds/panting.ogg")
func start_looping_sound(key: String):
	print(key)
	print(sound_paths)
	print("has key?")
	print(sound_paths.has(key))
	var path = sound_paths.get(key, "NOT_FOUND!!!")
	print(path)
	var sound_effect = load(path)
	
	if sound_effect:
		loop_player.stream = sound_effect
		loop_player.volume_db = 15 # increase volume for footsteps
		loop_player.play()
	else:
		push_error("Could not find sound file at: " + path)

## Stops the sound with a smooth fade-out
func stop_looping_sound(fade_duration: float = 0.3):
	if loop_player.playing:
		# Create a tween to transition the volume to silence (-80 dB)
		var tween = create_tween()
		tween.tween_property(loop_player, "volume_db", -80.0, fade_duration)
		
		# Once the fade is done, actually stop the player
		tween.finished.connect(func(): 
			loop_player.stop()
			loop_player.volume_db = 0 # Reset volume
		)

func next_scene():
	var fade_duration = 0.5
	if music_player.playing:
		# Create a tween to transition the volume to silence (-80 dB)
		var tween = create_tween()
		tween.tween_property(music_player, "volume_db", -80.0, fade_duration)
		
		# Once the fade is done, actually stop the player
		tween.finished.connect(func(): 
			TransitionManager.go_to_scene_threaded(NEXT_SCENE)
		)
	else:
		TransitionManager.go_to_scene_threaded(NEXT_SCENE)

func get_new_dig_seconds() -> int:
	return DEFAULT_DIG_SECONDS if GameState.seen_intro else INTRO_DIG_SECONDS

func let_meter_run():
	ready_for_dig_complete = true
	var now: float = Time.get_unix_time_from_system()

	if now >= GameState.pending_dig.complete_time():
		complete_dig()
	else:
		print("waiting for timer to run out")

func start_dig_timer():
	pending_dig = GameState.pending_dig
	if (pending_dig):
		print("continuing pending dig")
		print(pending_dig)
	else:
		print("starting new dig:")
	var now: float = Time.get_unix_time_from_system()
	var start_time := pending_dig.start_unix_time if pending_dig else now
	var dig_seconds := pending_dig.duration_seconds if pending_dig else get_new_dig_seconds()
	var dig_complete_time: float = start_time + dig_seconds
	var remaining_time = max(0, dig_complete_time - now)
	GameState.start_dig(start_time, dig_seconds, bonki.appearance)
	
	print("starting dig timer")
	print("remaining seconds:")
	print(remaining_time)
	
	dig_meter.show()

	
	
	GameState.start_dig(start_time, dig_seconds, bonki.appearance)


func complete_dig():
	if (ready_for_dig_complete):
		dig_meter.hide()
		# otherwise we will complete dig after intro sequence finished in other scene.
		if (GameState.seen_intro):
			GameState.complete_dig()
		print("Digging complete!")
		jump_to_label("DOG_FINISHES_DIGGING")
	
func interrupt_dig():
	GameState.interrupt_dig()
	dig_meter.hide()
	print("Digging stopped!")
	ready_for_dig_complete = false
	


func _on_character_body_3d_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	# Check if the event is a mouse button click or a screen touch
	if event is InputEventMouseButton:
		print("dog tapped")
		if ready_for_dig_complete:
			jump_to_label("CONSIDER_GOING")
		## Check if it's the left mouse button and it was just pressed (not released) 
		#if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
	
