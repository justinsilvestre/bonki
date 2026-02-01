extends Control


@onready var cutscene_player = $AnimationPlayer
@onready var dialog_overlay = $UI_CanvasLayer/Overlay_Control
@onready var audio_player = $AudioStreamPlayer # Assuming you add this in Step 4

# Define the sequence steps. 
# "type": "text" -> show text logic
# "type": "anim" -> play animation logic
var sequence_steps = [
	{"type": "anim", "anim_name": "intro_sequence_01"}, # Moves camera, walks chars
	{"type": "text", "content": "Hello there."},
	{"type": "text", "content": "Welcome to Bonki Forest!"},
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
		print("Intro Finished - Load next scene here")
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
