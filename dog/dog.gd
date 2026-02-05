extends Node3D

@onready var anim_tree := $AnimationTree

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	stand()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func stand() -> void:
	anim_tree.set("parameters/StateMachine/conditions/is_standing", true)
	anim_tree.set("parameters/StateMachine/conditions/is_sitting", false)
	anim_tree.set("parameters/StateMachine/conditions/is_walking", false)
	anim_tree.set("parameters/StateMachine/conditions/is_jumping", false)
	anim_tree.set("parameters/StateMachine/conditions/is_digging", false)


func sit() -> void:
	anim_tree.set("parameters/StateMachine/conditions/is_sitting", true)
	anim_tree.set("parameters/StateMachine/conditions/is_standing", false)
	anim_tree.set("parameters/StateMachine/conditions/is_jumping", false)
	anim_tree.set("parameters/StateMachine/conditions/is_walking", false)
	anim_tree.set("parameters/StateMachine/conditions/is_digging", false)

func walk() -> void:
	anim_tree.set("parameters/StateMachine/conditions/is_walking", true)
	anim_tree.set("parameters/StateMachine/conditions/is_standing", false)
	anim_tree.set("parameters/StateMachine/conditions/is_sitting", false)
	anim_tree.set("parameters/StateMachine/conditions/is_jumping", false)
	anim_tree.set("parameters/StateMachine/conditions/is_digging", false)


func jump() -> void:
	anim_tree.set("parameters/JumpOneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	
	
func jump_on_loop() -> void:
	anim_tree.set("parameters/StateMachine/conditions/is_jumping", true)
	anim_tree.set("parameters/StateMachine/conditions/is_walking", false)
	anim_tree.set("parameters/StateMachine/conditions/is_standing", false)
	anim_tree.set("parameters/StateMachine/conditions/is_sitting", false)	
	anim_tree.set("parameters/StateMachine/conditions/is_digging", false)

func bark() -> void:
	anim_tree.set("parameters/BarkOneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)


func dig() -> void:
	anim_tree.set("parameters/StateMachine/conditions/is_digging", true)
	anim_tree.set("parameters/StateMachine/conditions/is_jumping", false)
	anim_tree.set("parameters/StateMachine/conditions/is_walking", false)
	anim_tree.set("parameters/StateMachine/conditions/is_standing", false)
	anim_tree.set("parameters/StateMachine/conditions/is_sitting", false)	
