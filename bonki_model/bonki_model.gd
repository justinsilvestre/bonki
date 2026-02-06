@tool
class_name BonkiModel
extends Node3D

# Hierarchy
@onready var anim_tree := $AnimationTree
@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var body_mesh: MeshInstance3D = $Armature/Skeleton3D/Body
@onready var eye_base_l_mesh: MeshInstance3D = $Armature/Skeleton3D/EyeBase_L
@onready var eye_base_r_mesh: MeshInstance3D = $Armature/Skeleton3D/EyeBase_R
@onready var crown_attachment: BoneAttachment3D = $CrownAttachment

var add_wide_stretch_path := "parameters/AddBodyWideStretch/add_amount"
var add_tall_stretch_path := "parameters/AddBodyTallStretch/add_amount"
var add_pearness_path := "parameters/AddBodyPearness/add_amount"
var add_antipearness_path := "parameters/AddBodyAntipearness/add_amount"
var add_eyes_spread_path := "parameters/AddEyesSpread/add_amount"
var add_eyes_tilt_path := "parameters/AddEyesTilt/add_amount"
var add_eyes_height_path := "parameters/AddEyesHeight/add_amount"

const EYES_SHUTNESS_BLEND_SHAPE_INDEX = 3
const EYES_SMILE_BLEND_SHAPE_INDEX = 4

func hide_eyes():
	eye_base_l_mesh.hide()
	eye_base_r_mesh.hide()
	
func show_eyes():
	eye_base_l_mesh.show()
	eye_base_r_mesh.show()

func close_eyes():
	eye_base_l_mesh.set_blend_shape_value(EYES_SHUTNESS_BLEND_SHAPE_INDEX, 1)
	eye_base_r_mesh.set_blend_shape_value(EYES_SHUTNESS_BLEND_SHAPE_INDEX, 1)
	
func open_eyes():
	eye_base_l_mesh.set_blend_shape_value(EYES_SHUTNESS_BLEND_SHAPE_INDEX, 0)
	eye_base_r_mesh.set_blend_shape_value(EYES_SHUTNESS_BLEND_SHAPE_INDEX, 0)
	pass
	
func stand():
	anim_tree.set("parameters/StateMachine/conditions/is_jumping", false)
	anim_tree.set("parameters/StateMachine/conditions/is_sleeping", false)
	anim_tree.set("parameters/StateMachine/conditions/is_swaying", false)
	open_eyes()
	

func start_sway():
	anim_tree.set("parameters/StateMachine/conditions/is_jumping", false)
	anim_tree.set("parameters/StateMachine/conditions/is_sleeping", false)
	anim_tree.set("parameters/StateMachine/conditions/is_swaying", true)
	open_eyes()

func start_sleep():
	anim_tree.set("parameters/StateMachine/conditions/is_jumping", false)
	anim_tree.set("parameters/StateMachine/conditions/is_sleeping", true)
	anim_tree.set("parameters/StateMachine/conditions/is_swaying", false)
	close_eyes()
	
func start_jumping():
	anim_tree.set("parameters/StateMachine/conditions/is_jumping", true)
	anim_tree.set("parameters/StateMachine/conditions/is_sleeping", false)
	anim_tree.set("parameters/StateMachine/conditions/is_swaying", false)
	open_eyes()

func jump():
	anim_tree.set("parameters/JumpOneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	eye_base_l_mesh.set_blend_shape_value(EYES_SMILE_BLEND_SHAPE_INDEX, 1)
	eye_base_r_mesh.set_blend_shape_value(EYES_SMILE_BLEND_SHAPE_INDEX, 1)
	await anim_tree.animation_finished
	
	eye_base_l_mesh.set_blend_shape_value(EYES_SMILE_BLEND_SHAPE_INDEX, 0)
	eye_base_r_mesh.set_blend_shape_value(EYES_SMILE_BLEND_SHAPE_INDEX, 0)
	



# Should be set by Bonki.appearance, and point to same resource
var appearance: BonkiAppearanceParameters:
	set(new_val): # Should be called automatically at scene instantiation
		# Skip appearance changes during CI build or in headless mode
		if OS.has_environment("GODOT_CI_BUILD") or DisplayServer.get_name() == "headless":
			appearance = new_val
			return
		if appearance == new_val: return # no-op if unchanged
		if new_val != null:
			# temporary connection. not visible to editor or saved to .tscn
			new_val.changed.connect(_on_appearance_changed.bind(appearance, new_val))
			pass
		_on_appearance_changed(appearance, new_val)
		appearance = new_val
		pass

# Cached variables from appearance changes
var _crown_pscn: PackedScene = null:
	set(new_val):
		# Skip crown instantiation during CI build or in headless mode
		if OS.has_environment("GODOT_CI_BUILD") or DisplayServer.get_name() == "headless":
			_crown_pscn = new_val
			return
		if _crown_pscn == new_val: return # no-op if unchanged
		if new_val != null:
			var new_inst =  new_val.instantiate()
			if new_inst is Crown:
				#_crown_node = new_val.instantiate() # attach new crown
				_crown_node = new_inst # attach new crown
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

func _on_appearance_changed(old_appearance: BonkiAppearanceParameters, new_appearance: BonkiAppearanceParameters):
	if new_appearance == null: return # TODO: maybe reset appearance to default?
	set_colors(old_appearance, new_appearance)
	set_dimensions(old_appearance, new_appearance)
	_crown_pscn = new_appearance.crown_pscn

func set_colors(old_params: BonkiAppearanceParameters, params: BonkiAppearanceParameters):
	if params == null: return
	
	var body_material: ShaderMaterial = preload(
		"res://bonki_model/materials/bonki_model_body_material.tres"
	).duplicate()  # surface override or material
	body_material.set_shader_parameter("albedo", params.body_color)
	body_mesh.set_surface_override_material(0, body_material)	
	
	var eye_base_material: ShaderMaterial = preload(
		"res://bonki_model/materials/bonki_eye_shader.tres"
	).duplicate()
	eye_base_material.set_shader_parameter("base_color", params.eye_base_color)
	eye_base_material.set_shader_parameter("shine_color", params.eye_shine_color)
	eye_base_material.set_shader_parameter("shadow_color", params.eye_shadow_color)

	
	eye_base_l_mesh.set_surface_override_material(0, eye_base_material)
	eye_base_r_mesh.set_surface_override_material(0, eye_base_material)
	

func set_dimensions(old_params: BonkiAppearanceParameters, params: BonkiAppearanceParameters):
	if params == null: return
	var was_blank := old_params == null
	
	if (was_blank or old_params.wide_stretch_factor != params.wide_stretch_factor):
		set_animation_appearance_parameter(add_wide_stretch_path, params.wide_stretch_factor)
	if (was_blank or old_params.horn_stretch_factor != params.horn_stretch_factor):
		set_body_shape_key("HornStretch", params.horn_stretch_factor)
	if (was_blank or old_params.pearness_factor != params.pearness_factor):
		if (params.pearness_factor == 0.0):
			set_animation_appearance_parameter(add_pearness_path, params.pearness_factor)
			set_animation_appearance_parameter(add_antipearness_path, params.pearness_factor)
		elif (params.pearness_factor > 0.0):
			set_animation_appearance_parameter(add_pearness_path, params.pearness_factor)
			set_animation_appearance_parameter(add_antipearness_path, 0)
		else:
			set_animation_appearance_parameter(add_pearness_path, 0)
			set_animation_appearance_parameter(add_antipearness_path, -params.pearness_factor)
	if (was_blank or old_params.long_stretch_factor != params.long_stretch_factor):
		set_body_shape_key("LongStretch", params.long_stretch_factor)
	if (was_blank or old_params.tall_stretch_factor != params.tall_stretch_factor):
		set_animation_appearance_parameter(add_tall_stretch_path, params.tall_stretch_factor)
	if (was_blank or old_params.wonkiness_factor != params.wonkiness_factor):
		set_body_shape_key("Wonkiness", params.wonkiness_factor)

	if (was_blank or old_params.eyes_spread_factor != params.eyes_spread_factor):
		set_animation_appearance_parameter(add_eyes_spread_path, params.eyes_spread_factor * 0.5)
	if (was_blank or old_params.eyes_tilt_factor != params.eyes_tilt_factor):
		set_animation_appearance_parameter(add_eyes_tilt_path, params.eyes_tilt_factor)
	if (was_blank or old_params.eyes_height_factor != params.eyes_height_factor):
		set_animation_appearance_parameter(add_eyes_height_path, params.eyes_height_factor * (1 - absf(params.pearness_factor) * 0.3) - params.pearness_factor * 0.3)
	

func set_animation_appearance_parameter(path: String, value: float) -> void:
	anim_tree.set(path, value)
	

func set_body_shape_key(blend_shape: String, value: float) -> void:
	var index = body_mesh.find_blend_shape_by_name(blend_shape)
	body_mesh.set_blend_shape_value(index, value)

func set_eyes_shape_key(blend_shape: String, value: float) -> void:
	var l_index = eye_base_l_mesh.find_blend_shape_by_name(blend_shape)
	eye_base_l_mesh.set_blend_shape_value(l_index, value)

	var r_index = eye_base_r_mesh.find_blend_shape_by_name(blend_shape)
	eye_base_r_mesh.set_blend_shape_value(r_index, value)
