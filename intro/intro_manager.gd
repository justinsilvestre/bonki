extends Control

signal step_finished

@onready var cutscene_player = $AnimationPlayer
@onready var dialog_overlay := $UI_CanvasLayer/Overlay_Control
@onready var loop_player : AudioStreamPlayer = $AudioStreamPlayer
@onready var music_player: AudioStreamPlayer = $Music_AudioStreamPlayer
@onready var sfx_player: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var bonki: Bonki = $SubViewportContainer/SubViewport/World_Node3D/Bonki
@onready var dog := $SubViewportContainer/SubViewport/World_Node3D/DogModel

@onready var dig_timer = $DigTimer
@onready var dig_meter = $UI_CanvasLayer/DigMeter

@onready var dog_name := GameState.dog_name


# we don't want to trigger the final bonki reveal until e.g. any text prompts are complete
var ready_for_dig_complete := false
var pending_dig: PendingDig = null

const DEFAULT_DIG_SECONDS = 30

const NEXT_SCENE = "res://bonki_spring/bonki_spring.tscn"


var sound_paths := {
	"footsteps": "res://sound/sfx/pixabay_footsteps-dirt-gravel.mp3"
}

# Define the sequence steps. 
# "type": "text" -> show text logic
# "type": "anim" -> play animation logic
# "type": "spec" -> trigger special behavior
# "type": "text_input" -> text input prompt
# "type": "choice" -> multiple choice input prompt
var sequence_steps := [
	{"type": "anim", "anim_name": "1_01__start"}, # black screen
	
	#{"type": "spec", "action": "start"},# start BG music, start footsteps sound
	{"type": "text", "content": "The air is thick with the soothing fragrance of pine."},
	#{"type": "spec", "action": "next_scene"},
	{"type": "text", "content": "It almost makes you forget just how long you've been lost in Bonki Forest."},
	{"type": "text", "content": "You haven't seen another soul in at least..."},
	{"type": "text", "content": "How long has it been, again?"},
	# sound of dog running behind you left to right
	{"type": "anim", "anim_name":"1_02__dog_runs_behind"},
	# footsteps stop, black fades to reveal empty scene
	#{"type": "anim", "anim_name":"1_03__reveal_scene"},
	{"type": "text", "content": "What was that?"},
	# sound of dog running behind you right to left to right
	{"type": "anim", "anim_name": "1_03__dog_runs"},
	{"type": "text", "content": "Who's there?"},
	# dog appears on scene, camera pans to reveal dog with wagging tail
	{"type": "anim", "anim_name": "1_04__dog_appears"},
	
	{"type": "text", "content": "Would you look at that!"},
	{"type": "text", "content": "You're not alone in these woods after all."},
	# dog greets you
	{"type": "anim", "anim_name": "1_05__dog_greets"},
	{"type": "text_input", "content": "What shall we call you?"},
	#{"type": "text_input_prompt", "content": "Name", "default": "Doggo"},
	{"type": "text", "content": "Yes, they're definitely a DOG."},
	# dog barks a couple times.
	{"type": "anim", "anim_name": "1_06__dog_barks"},
	{"type": "text", "content": "Easy now, DOG!"},
	# dog barks a couple times more.
	{"type": "anim", "anim_name": "1_07__dog_barks"}, 
	{"type": "text", "content": "What's the matter?"},
	# dog runs off screen
	{"type": "anim", "anim_name": "1_08__dog_runs_off"},
	{"type": "text", "content": "Maybe DOG knows the way out!"}, 
	{"type": "text", "content": "Quickly, now!"},
	# camera pans in dog's direction + fades to black.
	{"type": "anim", "anim_name": "1_09__follow_dog"},
	# random bonki crown now sticks out of ground next to dog, now in center of ground surface
	{"type": "spec", "action": "refresh_bonki", "next": true},
	# you catch up to the dog, i.e. camera jumps to opposite edge of screen, pans in same direction as last pan as screen fades from black
	{"type": "anim", "anim_name": "1_10__catch_up_to_dog"},
	{"type": "text", "content": "This isn't the way out..."},
	{"type": "text", "content": "Why did DOG bring you here?"},
	{"type": "text", "content": "Wait."},
	{"type": "text", "content": "What's that?"},
	# camera pans down towards bonki crown sticking out of ground
	{"label": "NOTICE_BONKI", "type": "anim", "anim_name": "1_11__notice_bonki"},
	{"type": "text", "content": "You've never seen anything like it."},
	{"type": "text", "content": "And yet..."},
	{"type": "text", "content": "It feels familiar."},
	
	# prompt yes/no
	{
		"type": "choice", "content": "What will you do?",
  		"options": ["Keep a respectful distance.", "Yank it out!"],
		"action": "decide_about_picking",
	},
	# if yes (pick it), camera lowers and dog barks
	# if no (don't pick it), dog starts digging
	# camera lowers toward bonki, dog barks and camera moves back fast
	{"label": "TRY_PICKING", "type": "anim", "anim_name": "2_01__dog_warns"},
	{"type": "text", "content": "Oh, DOG didn't like that..."},
	# prompt go left/wait here a bit/go right
	{
		"type": "choice",
		"content": "What shall you do?",
		"options": ["Wait here a bit", "Move left", "Move right"],
		"action": "decide_about_moving",
	},
	
	# if 'wait here a bit', dog starts digging
	# if move left or right, refresh bonki
	{"label": "REFRESH_BONKI_TO_LEFT", "type": "anim", "anim_name": "3_001_follow_dog_to_left"},
	{"type": "spec", "action": "refresh_bonki", "next": true},
	
	# camera jumps to opposite edge of screen, pans in same direction as last pan while screen fades from black
	{"type": "anim", "anim_name": "3_01__catch_up_to_dog_to_left"},
	{"type": "text", "content": "This isn't the way out..."},
	{"type": "anim", "anim_name": "1_11__notice_bonki"},
	{"type": "text", "content": "What's that?"},
	{"type": "text", "content": "It feels familiar."},
	{
		"type": "choice", "content": "What will you do?",
  		"options": ["Let it grow in peace.", "Yank it out!"],
		"action": "decide_about_picking",
	},
	{"label": "REFRESH_BONKI_TO_RIGHT", "type": "anim", "anim_name": "3_002_follow_dog_to_right"},
	{"type": "spec", "action": "refresh_bonki", "next": true},
	# camera jumps to opposite edge of screen, pans in same direction as last pan while screen fades from black
	{"type": "anim", "anim_name": "3_02__catch_up_to_dog_to_right"},
	{"type": "text", "content": "This isn't the way out..."},
	{"type": "anim", "anim_name": "1_11__notice_bonki"},
	{"type": "text", "content": "What's that?"},
	{"type": "text", "content": "It feels familiar."},
	{
		"type": "choice", "content": "What will you do?",
  		"options": ["Observe it in silence.", "Yank it out!"],
		"action": "decide_about_picking",
	},
	
	# dog starts digging
	{"label": "DOG_STARTS_DIGGING", "type": "anim", "anim_name": "4_01__dog_starts_digging"},
	{"type": "spec", "action": "start_dig_timer", "next": true },
	{"label": "CONSIDER_GOING", "type": "text", "content": "DOG seems to be enjoying themself."},
	{"type": "text", "content": "But perhaps we should keep searching for the way out..."},
	# dog keeps digging, meter starts
	# prompt yes/no
	{"type": "choice", "content": "What will you do?", "options": ["Wait and see what\nDOG digs up.", "Chop chop! Gotta go!"], "action": "confirm_about_staying"},
	# if yes (get going), call DOG
	# if no, wait until dog finished digging
	
	# when reopening game
	{"label": "DOG_CONTINUES_DIGGING", "type": "anim", "anim_name": "4_02__dog_continues_digging"},
	{"label": "LET_METER_RUN", "type": "spec", "action": "let_meter_run"},
	
	
	# call DOG
	{"label": "CALL_DOG", "type": "spec", "action": "interrupt_dig", "next": true},
	{"type": "text", "content": "Here, DOG!"},
	{"type": "anim", "anim_name": "5_01__dog_stops_digging"},
	
	{
		"type": "choice",
		"content": "What shall you do?",
		"options": ["Wait here a bit", "Move left", "Move right"],
		"action": "decide_about_moving"
	},
	# prompt go left/wait here a bit/go right — SAME AS ABOVE
	
	# wait until dog finished digging
	{"label": "DOG_FINISHES_DIGGING", "type": "anim", "anim_name": "6_01__dog_finishes_digging"},
	# bonki is unearthed
	{"type": "anim", "anim_name": "6_02__bonki_is_unearthed"},
	{"type": "text", "content": "What on Earth?"},
	# bonki runs away, dog runs after
	{"type": "anim", "anim_name": "6_03__they_run_off"},
	{"type": "text", "content": "There's no way..."},
	# dog barks
	{"type": "anim", "anim_name": "6_04__bark_in_distance"},
	{"type": "text", "content": "Wait up!"},
	# camera pans fast, black, running footsteps sound starts
	{"type": "anim", "anim_name": "6_05__fade_to_black"},
	{"type": "text", "content": "Were the stories all true?"},
	{"type": "text", "content": "Even if they were, no one's reported a sighting in ages..."},
	{"type": "text", "content": "..."},
	{"type": "text", "content": "But still..."},
	{"type": "text", "content": "You've got to make sure."},
	{"type": "text", "content": "You can't let it get away!"},
	{"type": "text", "content": "Run, DOG!"},
	{"type": "text", "content": "Follow that creature!"},
	{"type": "spec", "action": "next_scene"},
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
	
	dig_timer.timeout.connect(complete_dig)
	
	# Start the sequence
	start_step()
	

func _process(_delta):
	if !dig_timer.is_stopped():
		dig_meter.value = (dig_timer.time_left / dig_timer.wait_time) * 100

func start_step():
	if (current_step_index >= sequence_steps.size()):
		return
	var step = sequence_steps[current_step_index]
	print(step)
	
	
	if step["type"] == "text":
		dialog_overlay.show_text(step["content"].replace("DOG", dog_name))
		# We now wait for the 'step_finished' signal from the UI
		
	elif step["type"] == "anim":
		dialog_overlay.hide()
		cutscene_player.play(step["anim_name"])
		# We now wait for the 'animation_finished' signal from the Player

	elif step["type"] == "spec":
		dialog_overlay.hide()
		if has_method(step["action"]):
			call(step["action"])
		if ("next" in step and step["next"] == true):
			_on_step_finished()
		elif ("next" in step):
			jump_to_label(step["next"])

	elif step["type"] == "choice": 
		dialog_overlay.show_choices(step["content"], step["options"].map(func (s): return s.replace("DOG", dog_name)))

	elif step["type"] == "text_input":
		var default = step.get("default", dog_name) 
		dialog_overlay.show_text_input(step["content"], default)


func _on_step_finished():
	print("_on_step_finished")
	# Called when text is dismissed
	current_step_index += 1
	start_step()

func _on_anim_finished(anim_name):
	# Called when an animation finishes
	current_step_index += 1
	
	sfx_player.volume_db = 0 # Reset volume in case it was faded out
	start_step()
	
func jump_to_label(target_label: String):
	for i in range(sequence_steps.size()):
		var step = sequence_steps[i]
		if step.has("label") and step["label"] == target_label:
			current_step_index = i
			start_step()
			return
	print("Error: Label not found -> ", target_label)

func get_step_index_by_label(target_label: String):
	for i in range(sequence_steps.size()):
		var step = sequence_steps[i]
		if step.has("label") and step["label"] == target_label:
			return  i

func _on_choice_made(index: int):
	var step = sequence_steps[current_step_index]
	var action = step["action"]
	
	# Hide the choices immediately
	dialog_overlay.choice_container.hide()
	
	# Based on the "action" key, we decide where to go
	match action:
		"decide_about_picking":
			if index == 1: # Yes
				jump_to_label("TRY_PICKING")
			else: # No
				jump_to_label("DOG_STARTS_DIGGING")

		"decide_about_moving":
			if index == 0: 
				jump_to_label("DOG_STARTS_DIGGING")
			elif index == 1: 
				jump_to_label("REFRESH_BONKI_TO_LEFT")
			else: 
				jump_to_label("REFRESH_BONKI_TO_RIGHT")

		"confirm_about_staying":
			if index == 1: # (Get going / Call Dog)
				jump_to_label("CALL_DOG")
			else: # No (Wait)
				jump_to_label("LET_METER_RUN")

func _on_text_submitted(new_text: String):
	# Save the name!
	dog_name = new_text
	GameState.save_dog_name(dog_name)
	print("Name saved: ", dog_name)
	
	# Move to next step
	current_step_index += 1
	start_step()

# called in start animation step
func start():
	var bg_music = load("res://sound/kami-no-koe.mp3")
	
	if bg_music:
		music_player.stream = bg_music
		bg_music.loop = true
		music_player.volume_db = 0 
		music_player.play()
		
	start_looping_sound("footsteps")
	
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
		loop_player.volume_db = 0 # Reset volume in case it was faded out
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
	return DEFAULT_DIG_SECONDS

func let_meter_run():
	ready_for_dig_complete = true
	if !dig_timer.time_left:
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
	# Note: We keep wait_time as the TOTAL duration for the % math
	# but we start the timer with the REMAINING time.
	dig_timer.wait_time = GameState.pending_dig.duration_seconds
	dig_timer.start(remaining_time)
	
	
	GameState.start_dig(start_time, dig_seconds, bonki.appearance)


func complete_dig():
	dig_timer.stop()
	if (ready_for_dig_complete):
		dig_meter.hide()
		## REALLY SHOULD DO THIS AFTER NEXT SCENE
		GameState.complete_dig()
		print("Digging complete!")
		jump_to_label("DOG_FINISHES_DIGGING")
	
func interrupt_dig():
	GameState.interrupt_dig()
	dig_meter.hide()
	dig_timer.stop()
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
	
