@tool
class_name ScrollDemoBonki
extends "res://bonki.gd"


@export var scroll_velocity: Vector3 = Vector3.ZERO

func _ready():
	if Engine.is_editor_hint():
		pass
	else:
		velocity = scroll_velocity
		pass
		
	#body_color = Color(randf_range(0.8, 1), randf_range(0.8, 1), randf_range(0.8, 1))
	#eye_shine_color = Color(randf_range(0.5, 0.8), randf_range(0.5, 0.8), randf_range(0.5, 0.8))
	#eye_shadow_color = Color(randf(), randf(), randf())
	#eye_base_color = Color(randf(), randf(), randf())
	#
	#horn_stretch_factor = randf()
	#wide_stretch_factor = randf_range(-1, 1)
	#long_stretch_factor = randf_range(-1, 1)
	#pearness_factor = randf_range(-1, 1)
	#tall_stretch_factor = randf_range(-1, 1)
	#wonkiness_factor = randf_range(-1, 1)
	#eyes_closeness_factor = randf_range(-1.5, 1.5)
	#eyes_tilt_factor = randf_range(-1.5, 1.5)
	#eyes_height_factor = randf_range(-1, 1)
	
	super._ready()
	pass

func _physics_process(_delta: float) -> void:
	if Engine.is_editor_hint():
		pass
	else:
		move_and_slide()
		pass
	# super._physics_process(_delta)
	pass
