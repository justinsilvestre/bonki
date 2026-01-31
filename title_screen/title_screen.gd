extends Control

@export var main_scene: String = "res://intro/intro.tscn"
@export var intro_scene: String = "res://intro/intro.tscn"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("title_screen ready")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		print("InputEventMouseButton")
		go_to_next_scene()
	elif event is InputEventScreenTouch and event.is_pressed():
		print("InputEventScreenTouch")
		go_to_next_scene()
	

func go_to_next_scene():
	if GameState.seen_intro:
		TransitionManager.go_to_scene_threaded(intro_scene)
	else:
		TransitionManager.go_to_scene_threaded(intro_scene)

	
