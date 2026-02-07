@tool
class_name Bonki
extends CharacterBody3D

@export var tap_animation := TapAnim.NONE
@export var default_animation := DefaultAnim.NONE
@export var disable_physics := true
@export var appearance: BonkiAppearanceParameters:
	set(val):
		appearance = val
		if is_node_ready(): model.appearance = val

@onready var model := $BonkiModel

var blink_blend_path := "parameters/AddBlink/add_amount"
var blink_one_shot_path := "parameters/BlinkOneShot/request"

var blinking = false
var blink_timer := 0.0
const MIN_BLINK_INTERVAL := 2.0
const MAX_BLINK_INTERVAL := 5.0

enum TapAnim {
	NONE
}
enum DefaultAnim {
	NONE,
	SWAY,
	SLEEP
}


func _ready() -> void:
	model.appearance = appearance
	match DefaultAnim:
		DefaultAnim.SWAY:
			model.start_sway()
		DefaultAnim.SLEEP:
			model.start_sleep()


func _process(delta: float) -> void:
	if (blinking):
		blink_timer -= delta
		if blink_timer <= 0.0:
			await do_blink()
			_reset_blink_timer()

func hide_eyes():
	model.hide_eyes()
	
func show_eyes():
	model.show_eyes()

func close_eyes():
	model.close_eyes()

func open_eyes():
	model.open_eyes()

func _start_blink_timer():
	blinking = true
	model.anim_tree.active = true
	_reset_blink_timer()

func _reset_blink_timer() -> void:
	blink_timer = randf_range(MIN_BLINK_INTERVAL, MAX_BLINK_INTERVAL)
	###print("resetting blink timer to")
	###print(blink_timer)

func do_blink() -> void:
	# Trigger blink blend
	#model.anim_tree.set(blink_blend_path, 1.0)
	###print("blinking!")
	###print(blink_one_shot_path)
	model.anim_tree.set(blink_one_shot_path, AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	###print("fired blink request")
	# Wait for duration of Blink animation
	var blink_length = model.anim_player.get_animation("Blink").length
	#var blink_length = 0.2
	
	var blinks_count = 1 if (randf() < 0.80) else 2
	###print("waiting seconds:")
	###print(blink_length * blinks_count)

	await get_tree().create_timer(blink_length * blinks_count).timeout

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

func _physics_process(delta: float) -> void:
	if disable_physics: return
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


func _on_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	# Check if the event is a mouse button click or a screen touch
	if event is InputEventMouseButton:
		# Check if it's the left mouse button and it was just pressed (not released)
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			play_tap_animation()


func play_tap_animation():
	# Example: Triggering a transition in your AnimationTree
	# Assuming you have a 'parameters/conditions/is_tapped' boolean in your tree
	#$AnimationTree.set("parameters/conditions/is_tapped", true)
	
	# If you use a 'OneShot' node, it would look like this:
	# $AnimationTree.set("parameters/OneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	
	print("Character animation triggered!")
	
	model.jump()
