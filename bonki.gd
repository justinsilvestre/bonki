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

	
@onready var anim_tree: AnimationTree = $BonkiModel/AnimationTree
@onready var blink_blend_path := "parameters/Add2/add_amount"
@onready var anim_player: AnimationPlayer = $BonkiModel/AnimationPlayer

var blink_timer := 0.0
const MIN_BLINK_INTERVAL := 2.0
const MAX_BLINK_INTERVAL := 5.0


func _start_blink_timer():
	print($BonkiModel/AnimationTree.get_property_list())
	anim_tree.active = true
	_reset_blink_timer()

func _process(delta: float) -> void:
	blink_timer -= delta
	if blink_timer <= 0.0:
		await _do_blink()
		_reset_blink_timer()

func _reset_blink_timer() -> void:
	blink_timer = randf_range(MIN_BLINK_INTERVAL, MAX_BLINK_INTERVAL)

func _do_blink() -> void:
	var anim_tree := $BonkiModel/AnimationTree
	var anim_player := $BonkiModel/AnimationPlayer
	# Trigger blink blend
	anim_tree.set(blink_blend_path, 1.0)

	# Wait for duration of Blink animation
	#var blink_length = anim_player.get_animation("Blink").length / 2
	var blink_length = 0.2
	
	var blinks_count = 1 if (randf() < 0.80) else 2

	await get_tree().create_timer(blink_length * blinks_count).timeout

	# Fade back to Idle_Sway
	anim_tree.set(blink_blend_path, 0.0)


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
	
	_start_blink_timer()
	




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
