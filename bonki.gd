@tool
extends CharacterBody3D

@export var body_color: Color = Color.CADET_BLUE
@export var eye_shine_color: Color = Color.AQUAMARINE
@export var eye_shadow_color: Color = Color.YELLOW
@export var eye_base_color: Color = Color.DARK_CYAN

@export var wide_stretch_factor: float = 0
@export var horn_stretch_factor: float = 0
@export var long_stretch_factor: float = 0
@export var pearness_factor: float = 0
@export var tall_stretch_factor: float = 0
@export var wonkiness_factor: float = 0
@export var eyes_closeness_factor: float = 0
@export var eyes_tilt_factor: float = 0
@export var eyes_height_factor: float = 0

#const SPEED = 5.0
#const JUMP_VELOCITY = 4.5

func _ready() -> void:
	var appearance_params = BonkiAppearanceParameters.new()
	appearance_params.body_color = body_color
	appearance_params.eye_shine_color = eye_shine_color
	appearance_params.eye_shadow_color = eye_shadow_color
	appearance_params.eye_base_color = eye_base_color
	appearance_params.wide_stretch_factor = wide_stretch_factor
	appearance_params.horn_stretch_factor = horn_stretch_factor
	appearance_params.long_stretch_factor = long_stretch_factor
	appearance_params.pearness_factor = pearness_factor
	appearance_params.tall_stretch_factor = tall_stretch_factor
	appearance_params.wonkiness_factor = wonkiness_factor
	appearance_params.eyes_closeness_factor = eyes_closeness_factor
	appearance_params.eyes_tilt_factor = eyes_tilt_factor
	appearance_params.eyes_height_factor = eyes_height_factor
	$BonkiModel.set_appearance(appearance_params)

#func _physics_process(delta: float) -> void:
	## Add the gravity.
	#if not is_on_floor():
		#velocity += get_gravity() * delta
#
	## Handle jump.
	#if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		#velocity.y = JUMP_VELOCITY
#
	## Get the input direction and handle the movement/deceleration.
	## As good practice, you should replace UI actions with custom gameplay actions.
	#var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	#var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	#if direction:
		#velocity.x = direction.x * SPEED
		#velocity.z = direction.z * SPEED
	#else:
		#velocity.x = move_toward(velocity.x, 0, SPEED)
		#velocity.z = move_toward(velocity.z, 0, SPEED)
#
	#move_and_slide()
