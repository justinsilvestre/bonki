@tool
extends Node3D

class_name BonkiModel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass
	
func set_appearance(params: BonkiAppearanceParameters):
	set_colors(params)
	set_dimensions(params)

func set_colors(params: BonkiAppearanceParameters) -> void:
	var body_color: Color = params.body_color
	var eye_shine_color: Color = params.eye_shine_color
	var eye_shadow_color: Color = params.eye_shadow_color
	var eye_base_color: Color = params.eye_base_color
	
	var body_mesh := $armature/Skeleton3D/armature
	var body_material: ShaderMaterial = body_mesh.get_active_material(0).duplicate()  # surface override or material
	body_mesh.set_surface_override_material(0, body_material)	
	body_material.set_shader_parameter("albedo", body_color)
		
	var eyes_mesh := $armature/Skeleton3D/eyes
	var eye_base_material_L: StandardMaterial3D = eyes_mesh.get_active_material(0)
	var eye_shadow_material_L: StandardMaterial3D = eyes_mesh.get_active_material(1)
	var eye_shine_material_LR: StandardMaterial3D = eyes_mesh.get_active_material(2)
	var eye_base_material := eye_base_material_L.duplicate()
	var eye_shadow_material := eye_shadow_material_L.duplicate()
	var eye_shine_material := eye_shine_material_LR.duplicate()
	eye_base_material.albedo_color = eye_base_color
	eye_shadow_material.albedo_color = eye_shadow_color
	eye_shine_material.albedo_color = eye_shine_color
	eyes_mesh.set_surface_override_material(0, eye_base_material)
	eyes_mesh.set_surface_override_material(3, eye_base_material)
	eyes_mesh.set_surface_override_material(1, eye_shadow_material)
	eyes_mesh.set_surface_override_material(4, eye_shadow_material)
	eyes_mesh.set_surface_override_material(2, eye_shine_material)
	

func set_dimensions(params: BonkiAppearanceParameters) -> void:
	var skull_stretch_factor := params.skull_stretch_factor
	var spine_base_spread_factor := params.spine_base_spread_factor
	#var spine_base_spread_factor: float = 3.0
	
	var skeleton := $armature/Skeleton3D
	var skull_index: int = skeleton.find_bone("skull")
	var spine_base_index: int = skeleton.find_bone("spine_base")
	
	print(spine_base_index)
	
	#var spine_neck_index = skeleton.find_bone("spine_neck")
	#var head_top_index = skeleton.find_bone("head_top")
	#var horn_index = skeleton.find_bone("horn")

	#skeleton.set_bone_pose_scale(spine_base_index, Vector3(spine_base_spread_factor, 1.0, spine_base_spread_factor))
	#skeleton.set_bone_pose_scale(skull_index, Vector3(1.0, skull_stretch_factor, 1.0))
	
	#var spine_base_rest =  Transform3D.IDENTITY.scaled(Vector3(spine_base_spread_factor, 1.0, spine_base_spread_factor))
	#var skull_rest := Transform3D.IDENTITY.scaled(Vector3(1.0, skull_stretch_factor, 1.0))
	#
	#skeleton.set_bone_rest(skull_index, skull_rest)
	#skeleton.set_bone_rest(spine_base_index, spine_base_rest)
	##skeleton.reset_bone_pose(spine_base_index)
	#skeleton.reset_bone_poses()
	#
	
	var anim := Animation.new()
	anim.length = 0
	var spine_base_track_index = anim.add_track(Animation.TYPE_SCALE_3D)
	anim.track_set_path(spine_base_track_index, "armature/Skeleton3D:spine_base")
	anim.scale_track_insert_key(spine_base_track_index, 0, Vector3(1.0, skull_stretch_factor, 1.0))
	
	var library := AnimationLibrary.new()
	library.add_animation("appearance", anim)
	var player : AnimationPlayer = $AnimationPlayer
	player.add_animation_library("appearance_lib", library)
	
	var tree := $AnimationTree
	#tree.set("parameters/BlendTree/Animation/animation", "shake")
	

	#for prop in $AnimationTree.get_property_list():
		##if "parameters/" in prop.name:
			#print(prop.name)
			#
	#print(tree.get_node("parameters/BlendTree/Animation").animation)
	for prop in $AnimationTree.tree_root.get_property_list():
	#if "parameters/" in prop.name:
		print(prop.name)
	print(tree.tree_root)
	#print(tree.tree_root.get_node("nodes/BlendTree/node"))
	print(tree.tree_root.get_node_list())
	print(tree.tree_root.get_node("BlendTree"))
	var blend_tree: AnimationNodeBlendTree = tree.tree_root.get_node("BlendTree")
	print(blend_tree.get_node_list())
	print(blend_tree.get_node("Animation").animation)
	#blend_tree.get_node("Animation").animation = "shake"
	print(blend_tree.get_node("Animation").animation)
		
	## Example: move the head up slightly
	##var head_idx = skeleton.find_bone("head")
	#if head_idx >= 0:
		#var rest = skeleton.get_bone_rest(head_idx)
		#rest.origin += Vector3(0, 0.1, 0)
		#skeleton.set_bone_rest(head_idx, rest)
		
