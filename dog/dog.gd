extends Node3D

@onready var anim_tree := $AnimationTree

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	anim_tree.set("parameters/StateMachine/conditions/is_standing", true)
	anim_tree.set("parameters/StateMachine/conditions/is_sitting", false)
	anim_tree.set("parameters/StateMachine/conditions/is_jumping", false)
	anim_tree.set("parameters/StateMachine/conditions/is_walking", false)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func stand() -> void:
	anim_tree.set("parameters/StateMachine/conditions/is_standing", true)
	anim_tree.set("parameters/StateMachine/conditions/is_sitting", false)
	anim_tree.set("parameters/StateMachine/conditions/is_walking", false)
	anim_tree.set("parameters/StateMachine/conditions/is_jumping", false)


func sit() -> void:
	anim_tree.set("parameters/StateMachine/conditions/is_sitting", true)
	anim_tree.set("parameters/StateMachine/conditions/is_standing", false)


func walk() -> void:
	anim_tree.set("parameters/StateMachine/conditions/is_walking", true)
	anim_tree.set("parameters/StateMachine/conditions/is_standing", false)


func jump() -> void:
	anim_tree.set("parameters/StateMachine/conditions/is_jumping", true)
	anim_tree.set("parameters/StateMachine/conditions/is_walking", false)
	anim_tree.set("parameters/StateMachine/conditions/is_standing", true)
	anim_tree.set("parameters/StateMachine/conditions/is_jumping", false)
	
func jump_on_loop() -> void:
	anim_tree.set("parameters/StateMachine/conditions/is_jumping", true)
	anim_tree.set("parameters/StateMachine/conditions/is_walking", false)
	anim_tree.set("parameters/StateMachine/conditions/is_standing", false)
	anim_tree.set("parameters/StateMachine/conditions/is_jumping", false)
	

func bark() -> void:
	anim_tree.set("parameters/BarkOneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
