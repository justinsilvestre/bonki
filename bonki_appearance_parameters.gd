@tool

class_name BonkiAppearanceParameters
extends Resource

@export_color_no_alpha var body_color: Color = Color.CADET_BLUE:
	set(val): var is_changed = body_color == val; body_color = val; if is_changed: emit_changed()
@export_color_no_alpha var eye_shine_color: Color = Color.AQUAMARINE:
	set(val): eye_shine_color = val; emit_changed()
@export_color_no_alpha var eye_shadow_color: Color = Color.YELLOW:
	set(val): eye_shadow_color = val; emit_changed()
@export_color_no_alpha var eye_base_color: Color = Color.DARK_CYAN:
	set(val): eye_base_color = val; emit_changed()

@export_range(-1, 1, 0.1) var wide_stretch_factor: float = 0:
	set(val): wide_stretch_factor = val; emit_changed()
@export_range(0, 1, 0.1) var horn_stretch_factor: float = 0:
	set(val): horn_stretch_factor = val; emit_changed()
@export_range(-1, 1, 0.1) var long_stretch_factor: float = 0:
	set(val): long_stretch_factor = val; emit_changed()
@export_range(-1, 1, 0.1) var pearness_factor: float = 0:
	set(val): pearness_factor = val; emit_changed()
@export_range(-1, 1, 0.1) var tall_stretch_factor: float = 0:
	set(val): tall_stretch_factor = val; emit_changed()
@export_range(-1, 1, 0.1) var wonkiness_factor: float = 0:
	set(val): wonkiness_factor = val; emit_changed()
@export_range(-1, 1, 0.1) var eyes_spread_factor: float = 0:
	set(val): eyes_spread_factor = val; emit_changed()
@export_range(-1, 1, 0.1) var eyes_tilt_factor: float = 0:
	set(val): eyes_tilt_factor = val; emit_changed()
@export_range(-1, 1, 0.1) var eyes_height_factor: float = 0:
	set(val): eyes_height_factor = val; emit_changed()

@export var crown_pscn: PackedScene = null:
	set(new_value): crown_pscn = new_value; emit_changed()

@export_tool_button("Randomize")
var randomize_action: Callable = randomize

# Use paths instead of preloads to avoid loading everything at startup
const crown_choice_paths = [
	# null,
	# "res://bonki_model/crowns/donut_crown.tscn",
	"res://bonki_model/crowns/chanterelle/chanterelle_crown.tscn",
	"res://bonki_model/crowns/christmas_rose/christmas_rose_crown.tscn",
	"res://bonki_model/crowns/enoki/enoki_crown.tscn",
	"res://bonki_model/crowns/yellow_stagshorn/yellow_staghorn_crown.tscn",
	"res://bonki_model/crowns/pincushion_moss/pincushion_moss_crown.tscn",
	"res://bonki_model/crowns/porcini/porcini_crown.tscn",
	"res://bonki_model/crowns/kale/kale_crown.tscn",
	"res://bonki_model/crowns/cladonia/cladonia_crown.tscn",
]

# Lazy loading getter for crown choices  
var _crown_choices_cache: Array[PackedScene] = []
var crown_choices: Array[PackedScene]:
	get:
		if _crown_choices_cache.is_empty() and not (OS.has_environment("GODOT_CI_BUILD") or DisplayServer.get_name() == "headless"):
			for path in crown_choice_paths:
				_crown_choices_cache.append(load(path))
		return _crown_choices_cache
const body_colors = [
	# null,
	# preload("res://bonki_model/crowns/donut_crown.tscn"),
	[[30, 45], [0.7,0.9], [0.8,0.9]], # yellow
	[[182, 195], [0.3,0.4], [0.7,0.9]], # preload("res://bonki_model/crowns/christmas_rose_crown.tscn"),
	[[20, 39], [0.6,0.7], [0.5,0.6]], # preload("res://bonki_model/crowns/enoki_crown.tscn"),
	[[42, 56], [0.8,1], [0.5,0.7]], # preload("res://bonki_model/crowns/yellow_staghorn_crown.tscn"),
	[[70, 100], [0.3,0.4], [0.3,0.7]], # preload("res://bonki_model/crowns/pincushion_moss_crown.tscn"),
	[[0, 27], [0.3,0.4], [0.7,0.9]], # preload("res://bonki_model/crowns/porcini_crown.tscn"),
	[[110, 119], [0.3,0.5], [0.3,0.7]], # preload("res://bonki_model/crowns/kale_crown.tscn"),
	[[124, 145], [0.3,0.4], [0.5,0.7]], # preload("res://bonki_model/crowns/cladonia_crown.tscn"),
]

func randomize():
	# Skip randomization during CI build or in headless mode
	if OS.has_environment("GODOT_CI_BUILD") or DisplayServer.get_name() == "headless":
		return
		
	var crown_index = randi_range(0, crown_choices.size() - 1)
	var colors = body_colors[crown_index]
	var hue = colors[0]
	var sat = colors[1]
	var lig = colors[2]
	var body_hue_angle : int = randi_range(colors[0][0], colors[0][1]) 
	var body_hue: float = body_hue_angle / 360.0

	var eye_hue := body_hue + randf_range(0.1, 0.5)
	if (eye_hue > 1): eye_hue -= 1
	var eye_shadow_hue := eye_hue + randf_range(0, 0.5)
	if (eye_shadow_hue > 1): eye_shadow_hue -= 1
	
	body_color = Color.from_hsv(body_hue, randf_range(sat[0], sat[1]),randf_range(lig[0], lig[1]))
	eye_base_color = Color.from_ok_hsl(eye_hue, randf_range(0.3, 0.7), randf_range(0.3, 0.7))
	eye_shadow_color = Color.from_ok_hsl(eye_shadow_hue, randf_range(0.7, 1), randf_range(0.3, 0.8))
	eye_shine_color = Color.from_ok_hsl(eye_hue, randf_range(0.3, 0.5), randf_range(0.8, 1))
	
	horn_stretch_factor = randf_range(0,0.4)
	wide_stretch_factor = randf_range(-1, 1)
	long_stretch_factor = randf_range(-1, 1)
	pearness_factor = randf_range(-1, 1)
	tall_stretch_factor = randf_range(-1, 1)
	wonkiness_factor = randf_range(-1, 1)
	eyes_spread_factor = randf_range(-1, 1)
	eyes_tilt_factor = randf_range(-1, 1)
	eyes_height_factor = randf_range(-1, 1)
	
	crown_pscn = crown_choices[crown_index]
	pass

@export_tool_button("Reload crown")
var reload_crown_action: Callable = reload_crown
func reload_crown():
	var old_crown_pscn = crown_pscn
	crown_pscn = null
	crown_pscn = old_crown_pscn
	pass
