class_name Crown
extends Node3D

@onready var mesh_inst: MeshInstance3D = $Mesh
@export var tall_stretch_coeff: float = 0.2
@export var horn_stretch_coeff: float = 0.25

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if mesh_inst == null: return
	var _mesh: Mesh = mesh_inst.mesh
	
	# mesh.surface_get_blend_shape_arrays()
	
	var _blend_shape_count: int = mesh_inst.get_blend_shape_count()
	# var blend_shape_names: Array[String] = mesh.blend()
