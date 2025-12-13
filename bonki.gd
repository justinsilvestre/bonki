@tool
class_name Bonki
extends CharacterBody3D

@export var appearance: BonkiAppearanceParameters:
	set(val):
		appearance = val
		if is_node_ready(): model.appearance = val

@onready var model: BonkiModel = $BonkiModel
@onready var blink_blend_path := "parameters/AddBlink/add_amount"

var blink_timer := 0.0
const MIN_BLINK_INTERVAL := 2.0
const MAX_BLINK_INTERVAL := 5.0

func _start_blink_timer():
	# print($BonkiModel/AnimationTree.get_property_list())
	model.anim_tree.active = true
	_reset_blink_timer()

func _process(delta: float) -> void:
	blink_timer -= delta
	if blink_timer <= 0.0:
		await _do_blink()
		_reset_blink_timer()

func _reset_blink_timer() -> void:
	blink_timer = randf_range(MIN_BLINK_INTERVAL, MAX_BLINK_INTERVAL)

func _do_blink() -> void:
	# Trigger blink blend
	model.anim_tree.set(blink_blend_path, 1.0)

	# Wait for duration of Blink animation
	#var blink_length = anim_player.get_animation("Blink").length / 2
	var blink_length = 0.2
	
	var blinks_count = 1 if (randf() < 0.80) else 2

	await get_tree().create_timer(blink_length * blinks_count).timeout

	# Fade back to Idle_Sway
	model.anim_tree.set(blink_blend_path, 0.0)

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

func _ready() -> void:
	model.appearance = appearance
	_start_blink_timer()

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint(): return
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
