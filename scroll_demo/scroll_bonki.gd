@tool
class_name ScrollBonki
extends Bonki

@export var scroll_velocity: Vector3 = Vector3.ZERO

func _ready():
	if Engine.is_editor_hint(): return
	# Skip initialization during CI build or in headless mode
	if OS.has_environment("GODOT_CI_BUILD") or DisplayServer.get_name() == "headless":
		return
		
	model.appearance = BonkiAppearanceParameters.new()
	model.appearance.randomize()
	super._ready()
	
	velocity = scroll_velocity

func _physics_process(_delta: float):
	if Engine.is_editor_hint(): return
	move_and_slide()
