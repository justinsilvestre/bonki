@tool
class_name BonkiModel
extends Node3D

# Hierarchy
@onready var anim_tree: AnimationTree = $AnimationTree
@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var body_mesh: MeshInstance3D = $Armature/Skeleton3D/Body
@onready var eye_base_l_mesh: MeshInstance3D = $Armature/Skeleton3D/EyeBase_L
@onready var eye_shadow_l_mesh: MeshInstance3D = $Armature/Skeleton3D/EyeShadow_L
@onready var eye_shine_l_mesh: MeshInstance3D = $Armature/Skeleton3D/EyeShine_L
@onready var eye_base_r_mesh: MeshInstance3D = $Armature/Skeleton3D/EyeBase_R
@onready var eye_shadow_r_mesh: MeshInstance3D = $Armature/Skeleton3D/EyeShadow_R
@onready var eye_shine_r_mesh: MeshInstance3D = $Armature/Skeleton3D/EyeShine_R
@onready var crown_attachment: BoneAttachment3D = $CrownAttachment

# Should be set by Bonki.appearance, and point to same resource
var appearance: BonkiAppearanceParameters:
	set(new_val): # Should be called automatically at scene instantiation
		if appearance == new_val: return # no-op if unchanged
		if new_val != null:
			# temporary connection. not visible to editor or saved to .tscn
			new_val.changed.connect(_on_appearance_changed)
			pass
		appearance = new_val
		_on_appearance_changed()
		pass

# Cached variables from appearance changes
var _crown_pscn: PackedScene = null:
	set(new_val):
		if _crown_pscn == new_val: return # no-op if unchanged
		if new_val != null:
			var new_inst =  new_val.instantiate()
			if new_inst is Crown:
				_crown_node = new_val.instantiate() # attach new crown
			else:
				new_inst.queue_free()
				push_error("Crown Pscn must inherit from Crown!")
		else: _crown_node = null # despawn crown
		_crown_pscn = new_val
var _crown_node: Crown = null: # Should be set by _crown_pscn setter
	set(new_val):
		if _crown_node == new_val: return # no-op if unchanged
		if _crown_node != null: # Despawn previous if it's not null
			crown_attachment.remove_child(_crown_node)
			_crown_node.queue_free()
			_crown_node = null
		if new_val != null: # Attach new if it's not null
			# new_val.name = "crown"
			new_val.owner = null 
			var _old_y = new_val.position.y
			_crown_node_initial_y = new_val.position.y
			crown_attachment.add_child(new_val, false, INTERNAL_MODE_BACK)
		_crown_node = new_val
var _crown_node_initial_y: float = 0 

func _on_appearance_changed():
	if appearance == null: return # TODO: maybe reset appearance to default?
	set_colors(appearance)
	set_dimensions(appearance)
	_crown_pscn = appearance.crown_pscn
	
	if _crown_node != null:
		var crown_y_offset: float = 0
		crown_y_offset += appearance.tall_stretch_factor * _crown_node.tall_stretch_coeff
		crown_y_offset += appearance.horn_stretch_factor * _crown_node.horn_stretch_coeff
		_crown_node.position.y = _crown_node_initial_y + crown_y_offset

func set_colors(params: BonkiAppearanceParameters):
	if params == null: return
	
	var body_material: ShaderMaterial = preload(
		"res://bonki_model/materials/bonki_model_body_material.tres"
	).duplicate()  # surface override or material
	body_material.set_shader_parameter("albedo", params.body_color)
	body_mesh.set_surface_override_material(0, body_material)	
		
	var eye_base_material: StandardMaterial3D = preload(
		"res://bonki_model/materials/bonki_eye_material.tres"
	).duplicate()
	var eye_shadow_material: StandardMaterial3D = preload(
		"res://bonki_model/materials/bonki_eye_shadow_material.tres"
	).duplicate()
	var eye_shine_material: StandardMaterial3D = preload(
		"res://bonki_model/materials/bonki_eye_shine_material.tres"
	).duplicate()
	eye_base_material.albedo_color = params.eye_base_color
	eye_shadow_material.albedo_color = params.eye_shadow_color
	eye_shine_material.albedo_color = params.eye_shine_color
	
	eye_base_l_mesh.set_surface_override_material(0, eye_base_material)
	eye_base_r_mesh.set_surface_override_material(0, eye_base_material)
	
	eye_shadow_l_mesh.set_surface_override_material(0, eye_shadow_material)
	eye_shadow_r_mesh.set_surface_override_material(0, eye_shadow_material)
	
	eye_shine_l_mesh.set_surface_override_material(0, eye_shine_material)
	eye_shine_r_mesh.set_surface_override_material(0, eye_shine_material)
	

func set_dimensions(params: BonkiAppearanceParameters):
	if params == null: return
	
	set_dimension(0, params.wide_stretch_factor)
	set_dimension(1, params.horn_stretch_factor)
	set_dimension(2, params.long_stretch_factor)
	set_dimension(3, params.tall_stretch_factor)
	set_dimension(4, params.pearness_factor)
	set_dimension(5, params.wonkiness_factor)
	
	set_eyes_dimension(0, params.eyes_closeness_factor)
	set_eyes_dimension(1, params.eyes_tilt_factor)
	set_eyes_dimension(2, params.eyes_height_factor)

func set_dimension(index: int, value: float) -> void:
	if (value != 0.0):
		body_mesh.set_blend_shape_value(index, value)

func set_eyes_dimension(index:int, value: float) -> void:
	if (value != 0.0):
		eye_base_r_mesh.set_blend_shape_value(index, value)
		eye_base_l_mesh.set_blend_shape_value(index, value)
		eye_shadow_r_mesh.set_blend_shape_value(index, value)
		eye_shadow_l_mesh.set_blend_shape_value(index, value)
		eye_shine_r_mesh.set_blend_shape_value(index, value)
		eye_shine_l_mesh.set_blend_shape_value(index, value)
