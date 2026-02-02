extends Control


@onready var cutscene_player = $AnimationPlayer
@onready var dialog_overlay = $UI_CanvasLayer/Overlay_Control
@onready var audio_player = $AudioStreamPlayer # Assuming you add this in Step 4

const NEXT_SCENE = "res://bonki_spring/bonki_spring.tscn"

# Define the sequence steps. 
# "type": "text" -> show text logic
# "type": "anim" -> play animation logic
var sequence_steps = [
	{"type": "anim", "anim_name": "intro_sequence_01"}, # black screen, footsteps sound
	{"type": "text", "content": "The air is thick with the soothing fragrance of pine."},
	{"type": "text", "content": "It almost makes you forget just how long you've been lost in Bonki Forest."},
	{"type": "text", "content": "You haven't seen another soul in at least..."},
	{"type": "text", "content": "How long has it been, again?"},
	{"type": "anim", "anim_name":"RESET"},
	{"type": "text", "content": "What was that?"},
	{"type": "anim", "anim_name": "RESET"},
	{"type": "text", "content": "Who's there?"},
	{"type": "anim", "anim_name": "RESET"},
	{"type": "text", "content": "Would you look at that!"},
	{"type": "text", "content": "You're not alone in these woods after all."},
	{"type": "anim", "anim_name": "RESET"},
	{"type": "text", "content": "What shall we call you?"},
	#{"type": "text_input_prompt", "content": "Name", "default": "Doggo"},
	{"type": "anim", "anim_name": "RESET"},
	{"type": "text", "content": "Yes, they're definitely a DOG."},
	{"type": "anim", "anim_name": "RESET"},
	{"type": "text", "content": "Easy now, DOG!"},
	{"type": "anim", "anim_name": "RESET"},
	{"type": "text", "content": "What's the matter?"},
	{"type": "anim", "anim_name": "RESET"},
	{"type": "text", "content": "Maybe DOG knows the way out!"},
	{"type": "text", "content": "Quickly, now!"},
	{"type": "anim", "anim_name": "RESET"},
	# refresh bonki
	# first time seeing bonki: 
	{"type": "text", "content": "This isn't the way out..."},
	{"type": "text", "content": "Why did DOG bring you here?"},
	{"type": "text", "content": "Wait."},
	{"type": "text", "content": "What's that?"},
	{"type": "anim", "anim_name": "RESET"},
	{"type": "text", "content": "You've never seen anything like it.\n\nAnd yet..."},
	{"type": "text", "content": "It feels familiar."},
	{"type": "text", "content": "Shall you pick it?"},
	# 2nd + time seeing bonki:
	{"type": "text", "content": "This isn't the way out..."},
	{"type": "text", "content": "What's that?"},
	{"type": "text", "content": "It feels familiar."},
	{"type": "text", "content": "Shall you pick it?"},
	# prompt yes/no
	# if yes (pick it), camera lowers and dog barks
	# if no (don't pick it), dog starts digging
	{"type": "anim", "anim_name": "RESET"}, # camera lowers and dog barks
	{"type": "text", "content": "Oh, DOG didn't like that..."},
	{"type": "text", "content": "What shall you do?"},
	# prompt go left/wait here a bit/go right
	# if 'wait here a bit', dog starts digging
	# if move left or right, refresh bonki
	{"type": "anim", "anim_name": "RESET"}, # dog starts digging
	{"type": "text", "content": "DOG seems to be enjoying themself."},
	{"type": "text", "content": "But perhaps we should keep searching for the way out..."},
	{"type": "anim", "anim_name": "RESET"}, # dog keeps digging, meter starts
	{"type": "text", "content": "Shall we get going?"},
	# prompt yes/no
	# if yes (get going), call DOG
	# if no, wait until dog finished digging
	# call DOG
	{"type": "text", "content": "DOG!"},
	{"type": "anim", "anim_name": "RESET"},
	{"type": "text", "content": "Which way shall you go?"},
	# prompt go left/wait here a bit/go right --- SAME AS ABOVE
	{"type": "anim", "anim_name": "RESET"}, # wait until dog finished digging
	{"type": "anim", "anim_name": "RESET"}, # bonki is unearthed
	{"type": "text", "content": "What on Earth?"},
	{"type": "anim", "anim_name": "RESET"}, # bonki is unearthed, runs away
	{"type": "text", "content": "There's no way..."},
	{"type": "anim", "anim_name": "RESET"}, # dog runs after
	{"type": "text", "content": "Wait up!"},
	{"type": "anim", "anim_name": "RESET"}, # camera pan, black, footsteps
	{"type": "text", "content": "Were the stories all true?"},
	{"type": "text", "content": "Even if they were, no one's reported a sighting in ages..."},
	{"type": "text", "content": "..."},
	{"type": "text", "content": "But still..."},
	{"type": "text", "content": "You've got to make sure."},
	{"type": "text", "content": "You can't let it get away!"},
	{"type": "text", "content": "Run, DOG!"},
	{"type": "text", "content": "Follow that creature!"},
	{"type": "anim", "anim_name": "RESET"}, # transition to Bonki Spring
	{"type": "anim", "anim_name": "RESET"}, # pan around
	{"type": "text", "content": "Bonki Spring..."},
	{"type": "text", "content": "The mythical abode of the guardians of the forest--"},
	{"type": "text", "content": "The legendary Bonkis."},
	{"type": "text", "content": "It's clear now--\nthe reason you've been led here."},
	{"type": "text", "content": "The era of the Bonkis has returned!"},
	{"type": "text", "content": "You've been called to reawaken them with the help of DOG."},
	{"type": "text", "content": "Onward!"},
	{"type": "text", "content": "With a keen eye--\nand some patience--"},
	{"type": "text", "content": "Perhaps you'll unearth something even more incredible"},
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
	
	if step["type"] == "text":
		dialog_overlay.show_text(step["content"])
		# We now wait for the 'step_finished' signal from the UI
		
	elif step["type"] == "anim":
		cutscene_player.play(step["anim_name"])
		# We now wait for the 'animation_finished' signal from the Player

func _on_step_finished():
	# Called when text is dismissed
	current_step_index += 1
	start_step()

func _on_anim_finished(anim_name):
	# Called when an animation finishes
	current_step_index += 1
	start_step()
