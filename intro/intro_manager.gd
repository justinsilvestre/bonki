extends Control

signal step_finished

@onready var cutscene_player = $AnimationPlayer
@onready var dialog_overlay = $UI_CanvasLayer/Overlay_Control
@onready var audio_player = $AudioStreamPlayer

var dog_name := "Doggo"

const NEXT_SCENE = "res://bonki_spring/bonki_spring.tscn"

# Define the sequence steps. 
# "type": "text" -> show text logic
# "type": "anim" -> play animation logic
# "type": "spec" -> trigger special behavior
# "type": "text_input" -> text input prompt
# "type": "choice" -> multiple choice input prompt
var sequence_steps = [
	{"type": "anim", "anim_name": "1_01__start"}, # black screen
	{"type": "spec", "action": "start"},# start BG music, start footsteps sound
	{"type": "text", "content": "The air is thick with the soothing fragrance of pine."},
	{"type": "text", "content": "It almost makes you forget just how long you've been lost in Bonki Forest."},
	{"type": "text", "content": "You haven't seen another soul in at least..."},
	{"type": "text", "content": "How long has it been, again?"},
	# sound of dog running behind you left to right
	{"type": "anim", "anim_name":"1_02__dog_runs_behind"},
	# footsteps stop, black fades to reveal empty scene
	{"type": "anim", "anim_name":"1_03__reveal_scene"},
	{"type": "text", "content": "What was that?"},
	# sound of dog running behind you right to left to right
	{"type": "anim", "anim_name": "1_04__dog_runs"},
	{"type": "text", "content": "Who's there?"},
	# dog appears on scene, camera pans to reveal dog with wagging tail
	{"type": "anim", "anim_name": "1_05__dog_appears"},
	{"type": "text", "content": "Would you look at that!"},
	{"type": "text", "content": "You're not alone in these woods after all."},
	# dog greets you
	{"type": "anim", "anim_name": "1_06__dog_greets"},
	{"type": "text_input", "content": "What shall we call you?"},
	#{"type": "text_input_prompt", "content": "Name", "default": "Doggo"},
	{"type": "text", "content": "Yes, they're definitely a DOG."},
	# dog barks a couple times.
	{"type": "anim", "anim_name": "1_07__dog_barks"},
	{"type": "text", "content": "Easy now, DOG!"},
	# dog barks a couple times more.
	{"type": "anim", "anim_name": "1_08__dog_barks"}, 
	{"type": "text", "content": "What's the matter?"},
	# dog runs off screen
	{"type": "anim", "anim_name": "1_09__dog_runs_off"},
	{"type": "text", "content": "Maybe DOG knows the way out!"}, 
	{"type": "text", "content": "Quickly, now!"},
	# camera pans in dog's direction + fades to black.
	{"type": "anim", "anim_name": "1_10__follow_dog"},
	# random bonki crown now sticks out of ground next to dog, now in center of ground surface
	{"type": "spec", "action": "refresh_bonki"},
	# you catch up to the dog, i.e. camera jumps to opposite edge of screen, pans in same direction as last pan as screen fades from black
	{"type": "anim", "anim_name": "1_11__catch_up_to_dog"},
	{"type": "text", "content": "This isn't the way out..."},
	{"type": "text", "content": "Why did DOG bring you here?"},
	{"type": "text", "content": "Wait."},
	{"type": "text", "content": "What's that?"},
	# camera pans down towards bonki crown sticking out of ground
	{"type": "anim", "anim_name": "1_12__notice_bonki"},
	{"type": "text", "content": "You've never seen anything like it."},
	{"type": "text", "content": "And yet..."},
	{"type": "text", "content": "It feels familiar."},
	
	# prompt yes/no
	{
		"type": "choice", "content": "Shall you pick it?",
  		"options": ["Yes", "No"],
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
		"options": ["Go left", "Go right", "Wait here a bit"],
		"action": "decide_about_moving",
	},
	
	# if 'wait here a bit', dog starts digging
	# if move left or right, refresh bonki
	{"label": "REFRESH_BONKI_TO_LEFT", "type": "spec", "action": "refresh_bonki"},
	# camera jumps to opposite edge of screen, pans in same direction as last pan while screen fades from black
	{"type": "anim", "anim_name": "3_01__catch_up_to_dog_to_left"},
	{"type": "text", "content": "This isn't the way out..."},
	{"type": "text", "content": "What's that?"},
	{"type": "text", "content": "It feels familiar."},
	{
		"type": "choice", "content": "Shall you pick it?",
  		"options": ["Yes", "No"],
		"action": "decide_about_picking",
	},
	{"label": "REFRESH_BONKI_TO_RIGHT", "type": "spec", "action": "refresh_bonki"},
	# camera jumps to opposite edge of screen, pans in same direction as last pan while screen fades from black
	{"type": "anim", "anim_name": "3_02__catch_up_to_dog_to_right"},
	{"type": "text", "content": "This isn't the way out..."},
	{"type": "text", "content": "What's that?"},
	{"type": "text", "content": "It feels familiar."},
	{
		"type": "choice", "content": "Shall you pick it?",
  		"options": ["Yes", "No"],
		"action": "decide_about_picking",
	},
	
	# dog starts digging
	{"label": "DOG_STARTS_DIGGING", "type": "anim", "anim_name": "4_01__dog_starts_digging"},
	{"type": "text", "content": "DOG seems to be enjoying themself."},
	{"type": "text", "content": "But perhaps we should keep searching for the way out..."},
	# dog keeps digging, meter starts
	{"type": "spec", "action": "start_meter"},
	# prompt yes/no
	{"type": "choice", "content": "Shall we get going?", "options": ["Yes", "No"], "action": "confirm_about_staying"},
	# if yes (get going), call DOG
	# if no, wait until dog finished digging
	
	# call DOG
	{"label": "CALL_DOG", "type": "text", "content": "Here, DOG!"},
	# dog stops digging, meter stops
	{"type": "anim", "anim_name": "5_01__dog_stops_digging"},
	{"type": "spec", "action": "stop_meter"},
	
	{
		"type": "choice",
		"content": "Which way shall you go?",
		"options": ["Go left", "Go right", "Wait here a bit"],
		"action": "decide_about_moving"
	},
	# prompt go left/wait here a bit/go right — SAME AS ABOVE
	
	# wait until dog finished digging
	{"label": "WAIT_UNTIL_DIGGING_FINISHED", "type": "anim", "anim_name": "6_01__dog_finishes_digging"},
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
]
var bonki_spring_sequence_steps = [
	# transition to Bonki Spring
	{"type": "anim", "anim_name": "RESET"},
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

var current_step_index = 0

func _ready():
	# Connect the UI signal to our advance function
	dialog_overlay.step_finished.connect(_on_step_finished)
	
	# Connect the AnimationPlayer signal to our advance function
	cutscene_player.animation_finished.connect(_on_anim_finished)
	
	# Start the sequence
	start_step()

func start_step():
	if current_step_index >= sequence_steps.size():
		TransitionManager.go_to_scene_threaded(NEXT_SCENE)
		return

	var step = sequence_steps[current_step_index]
	print(step)
	
	if step["type"] == "text":
		dialog_overlay.show_text(step["content"])
		# We now wait for the 'step_finished' signal from the UI
		
	elif step["type"] == "anim":
		cutscene_player.play(step["anim_name"])
		# We now wait for the 'animation_finished' signal from the Player

	elif step["type"] == "spec":
		dialog_overlay.show_text(step["action"])

	elif step["type"] == "choice": 
		dialog_overlay.show_text(step["content"])

	elif step["type"] == "text_input":
		dialog_overlay.show_text(step["content"])


	

func _on_step_finished():
	# Called when text is dismissed
	current_step_index += 1
	start_step()

func _on_anim_finished(anim_name):
	# Called when an animation finishes
	current_step_index += 1
	start_step()
