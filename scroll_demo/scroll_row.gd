extends Node3D

@export var spawn_first_instantly: bool = false;
@export var spawn_wait: float = 5;
@export var child_velocity: Vector3 = Vector3.ZERO

var spawn_timer: float = 0
var scroll_bonki_pscn: PackedScene = preload("res://scroll_demo/scroll_bonki.tscn")

func _ready():
	spawn_timer = spawn_wait
	if spawn_first_instantly:
		_spawn_bonki()
		pass
	pass

func _process(delta: float):
	spawn_timer -= delta
	if spawn_timer < 0:
		spawn_timer += spawn_wait
		_spawn_bonki()
		pass
	pass

func _spawn_bonki():
	var new_bonki: ScrollBonki = scroll_bonki_pscn.instantiate()
	new_bonki.scroll_velocity = child_velocity
	add_child(new_bonki)
	pass
