extends MeshInstance3D

#@onready var silhouette_mesh = $SilhouetteEffect_MeshInstance3D # Adjust path as needed

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(_delta):
	# Make sure this is running in _process
	#var mat = silhouette_mesh.get_active_material(0)
	#mat.set_shader_parameter("pillar_pos", global_position)
	#mat.set_shader_parameter("radius", global_transform.basis.get_scale().x)
