extends Control


@export var next_scene: String = "res://main.tscn"
@export var fade_duration_sec: float = 0.35

@onready var fade: ColorRect = $FadeColorRect

var _transitioning := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _gui_input(event: InputEvent) -> void:
	# Control is the right place to handle UI input; _gui_input filters to relevant UI events. :contentReference[oaicite:14]{index=14}
	if _transitioning:
		return
		
	if event is InputEventMouseButton and event.is_pressed():
		print("InputEventMouseButton")
		_start_transition()
	elif event is InputEventScreenTouch and event.is_pressed():
		print("InputEventScreenTouch")
		_start_transition()
		
func _start_transition():
	_transitioning = true
		# Fade to black by tweening ColorRect alpha.
	var t := create_tween()
	var c := fade.color
	c.a = 0.0
	fade.color = c
	
	t.tween_property(fade, "color:a", 1.1, fade_duration_sec)
	await t.finished
	
	go_to_next_scene()

func go_to_next_scene():
	SceneLoader.load_scene_with_loading(next_scene)
	
