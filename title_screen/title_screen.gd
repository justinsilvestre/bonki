extends Control

@export var spring_scene: String = "res://bonki_spring/bonki_spring.tscn"
@export var forest_scene: String = "res://intro/intro.tscn"

@onready var anim_player := $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	TransitionManager.block_input()
	print("title_screen ready")
	anim_player.play("enter")
	await anim_player.animation_finished
	
	TransitionManager.free_input()
	anim_player.play("wobble")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		anim_player.play("exit")
		await anim_player.animation_finished
		if GameState.seen_intro:
			print("Starting game, intro already seen")
			TransitionManager.go_to_scene_threaded(spring_scene)
		else:
			print("Starting intro")
			print(GameState)
			TransitionManager.go_to_scene_threaded(forest_scene)
