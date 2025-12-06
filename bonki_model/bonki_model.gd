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
	
	var body_mesh := $Armature/Skeleton3D/Body
	var body_material: ShaderMaterial = body_mesh.get_active_material(0).duplicate()  # surface override or material
	body_mesh.set_surface_override_material(0, body_material)	
	body_material.set_shader_parameter("albedo", body_color)
		
	var eye_base_l_mesh := $Armature/Skeleton3D/EyeBase_L
	var eye_shadow_l_mesh := $Armature/Skeleton3D/EyeShadow_L
	var eye_shine_l_mesh := $Armature/Skeleton3D/EyeShine_L
	var eye_base_r_mesh := $Armature/Skeleton3D/EyeBase_R
	var eye_shadow_r_mesh := $Armature/Skeleton3D/EyeShadow_R
	var eye_shine_r_mesh := $Armature/Skeleton3D/EyeShine_R
	var eye_base_material_L: StandardMaterial3D = eye_base_l_mesh.get_active_material(0)
	var eye_shadow_material_L: StandardMaterial3D = eye_shadow_l_mesh.get_active_material(0)
	var eye_shine_material_LR: StandardMaterial3D = eye_shine_l_mesh.get_active_material(0)
	var eye_base_material := eye_base_material_L.duplicate()
	var eye_shadow_material := eye_shadow_material_L.duplicate()
	var eye_shine_material := eye_shine_material_LR.duplicate()
	eye_base_material.albedo_color = eye_base_color
	eye_shadow_material.albedo_color = eye_shadow_color
	eye_shine_material.albedo_color = eye_shine_color
	eye_base_l_mesh.set_surface_override_material(0, eye_base_material)
	eye_shadow_l_mesh.set_surface_override_material(0, eye_shadow_material)
	eye_shine_l_mesh.set_surface_override_material(0, eye_shine_material)
	eye_base_r_mesh.set_surface_override_material(0, eye_base_material)
	eye_shadow_r_mesh.set_surface_override_material(0, eye_shadow_material)
	eye_shine_r_mesh.set_surface_override_material(0, eye_shine_material)
	

func set_dimensions(params: BonkiAppearanceParameters) -> void:
	var wide_stretch_factor: float = params.wide_stretch_factor
	var horn_stretch_factor: float = params.horn_stretch_factor
	var long_stretch_factor: float = params.long_stretch_factor
	var pearness_factor: float = params.pearness_factor
	var tall_stretch_factor: float = params.tall_stretch_factor
	var wonkiness_factor: float = params.wonkiness_factor
	set_dimension(0, wide_stretch_factor)
	set_dimension(1, horn_stretch_factor)
	set_dimension(2, long_stretch_factor)
	set_dimension(3, tall_stretch_factor)
	set_dimension(4, pearness_factor)
	set_dimension(5, wonkiness_factor)
	
	var eyes_closeness_factor: float = params.eyes_closeness_factor
	var eyes_tilt_factor: float = params.eyes_tilt_factor
	var eyes_height_factor: float = params.eyes_height_factor
	set_eyes_dimension(0, eyes_closeness_factor)
	set_eyes_dimension(1, eyes_tilt_factor)
	set_eyes_dimension(2, eyes_height_factor)

func set_dimension(index: int, value: float) -> void:
	if (value != 0.0):
		$Armature/Skeleton3D/Body.set_blend_shape_value(index, value)

func set_eyes_dimension(index:int, value: float) -> void:
	if (value != 0.0):
		$Armature/Skeleton3D/EyeBase_R.set_blend_shape_value(index, value)
		$Armature/Skeleton3D/EyeBase_L.set_blend_shape_value(index, value)
		$Armature/Skeleton3D/EyeShadow_R.set_blend_shape_value(index, value)
		$Armature/Skeleton3D/EyeShadow_L.set_blend_shape_value(index, value)
		$Armature/Skeleton3D/EyeShine_R.set_blend_shape_value(index, value)
		$Armature/Skeleton3D/EyeShine_L.set_blend_shape_value(index, value)
		
