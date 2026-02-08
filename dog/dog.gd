extends Node3D

signal tapped

@onready var anim_tree := $AnimationTree

@export var dirt_textures: Array[Texture2D]


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	stand()

func new_dirt_texture():
	$DirtEffectsNode3D/Sprite3D.texture = dirt_textures.pick_random()
	$DirtEffectsNode3D/Sprite3D.rotation.z = randf_range(0, TAU)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _on_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	# Check if the event is a mouse button click or a screen touch
	if event is InputEventMouseButton:
		# Check if it's the left mouse button and it was just pressed (not released)
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			tapped.emit()


func stand() -> void:
	anim_tree.set("parameters/StateMachine/conditions/is_standing", true)
	anim_tree.set("parameters/StateMachine/conditions/is_sitting", false)
	anim_tree.set("parameters/StateMachine/conditions/is_walking", false)
	anim_tree.set("parameters/StateMachine/conditions/is_jumping", false)
	anim_tree.set("parameters/StateMachine/conditions/is_digging", false)
	$DirtEffectsNode3D/AnimationPlayer.play("RESET")

func sit() -> void:
	anim_tree.set("parameters/StateMachine/conditions/is_sitting", true)
	anim_tree.set("parameters/StateMachine/conditions/is_standing", false)
	anim_tree.set("parameters/StateMachine/conditions/is_jumping", false)
	anim_tree.set("parameters/StateMachine/conditions/is_walking", false)
	anim_tree.set("parameters/StateMachine/conditions/is_digging", false)
	$DirtEffectsNode3D/AnimationPlayer.play("RESET")

func walk() -> void:
	anim_tree.set("parameters/StateMachine/conditions/is_walking", true)
	anim_tree.set("parameters/StateMachine/conditions/is_standing", false)
	anim_tree.set("parameters/StateMachine/conditions/is_sitting", false)
	anim_tree.set("parameters/StateMachine/conditions/is_jumping", false)
	anim_tree.set("parameters/StateMachine/conditions/is_digging", false)
	$DirtEffectsNode3D/AnimationPlayer.play("RESET")

func jump() -> void:
	print("dog jumped!")
	anim_tree.set("parameters/JumpOneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	
	
func jump_on_loop() -> void:
	anim_tree.set("parameters/StateMachine/conditions/is_jumping", true)
	anim_tree.set("parameters/StateMachine/conditions/is_walking", false)
	anim_tree.set("parameters/StateMachine/conditions/is_standing", false)
	anim_tree.set("parameters/StateMachine/conditions/is_sitting", false)	
	anim_tree.set("parameters/StateMachine/conditions/is_digging", false)
	$DirtEffectsNode3D/AnimationPlayer.play("RESET")

func bark() -> void:
	anim_tree.set("parameters/BarkOneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)


func dig() -> void:
	anim_tree.set("parameters/StateMachine/conditions/is_digging", true)
	anim_tree.set("parameters/StateMachine/conditions/is_jumping", false)
	anim_tree.set("parameters/StateMachine/conditions/is_walking", false)
	anim_tree.set("parameters/StateMachine/conditions/is_standing", false)
	anim_tree.set("parameters/StateMachine/conditions/is_sitting", false)	
	$DirtEffectsNode3D/AnimationPlayer.play("dirt_throwing")

func look_up() -> void:
	anim_tree.set("parameters/LookUpBlend2/blend_amount", 1)
	
func start_wagging_tail() -> void:
	anim_tree.set("parameters/WagTailBlend2/blend_amount", 1)

func stop_wagging_tail() -> void:
	anim_tree.set("parameters/WagTailBlend2/blend_amount", 0)
	
