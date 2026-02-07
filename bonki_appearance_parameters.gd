@tool

class_name BonkiAppearanceParameters
extends Resource


@export_tool_button("Randomize")
var randomize_action: Callable = randomize

@export_color_no_alpha var body_color: Color = Color.CADET_BLUE:
	set(val): var is_changed = body_color == val; body_color = val; if Engine.is_editor_hint(): emit_changed()
@export_color_no_alpha var eye_shine_color: Color = Color.AQUAMARINE:
	set(val): eye_shine_color = val;if Engine.is_editor_hint(): emit_changed()
@export_color_no_alpha var eye_shadow_color: Color = Color.YELLOW:
	set(val): eye_shadow_color = val;if Engine.is_editor_hint(): emit_changed()
@export_color_no_alpha var eye_base_color: Color = Color.DARK_CYAN:
	set(val): eye_base_color = val;if Engine.is_editor_hint(): emit_changed()

@export_range(-1, 1, 0.1) var wide_stretch_factor: float = 0:
	set(val): wide_stretch_factor = val;if Engine.is_editor_hint(): emit_changed()
@export_range(0, 1, 0.1) var horn_stretch_factor: float = 0:
	set(val): horn_stretch_factor = val;if Engine.is_editor_hint(): emit_changed()
@export_range(-1, 1, 0.1) var long_stretch_factor: float = 0:
	set(val): long_stretch_factor = val;if Engine.is_editor_hint(): emit_changed()
@export_range(-1, 1, 0.1) var pearness_factor: float = 0:
	set(val): pearness_factor = val;if Engine.is_editor_hint(): emit_changed()
@export_range(-1, 1, 0.1) var tall_stretch_factor: float = 0:
	set(val): tall_stretch_factor = val;if Engine.is_editor_hint(): emit_changed()
@export_range(-1, 1, 0.1) var wonkiness_factor: float = 0:
	set(val): wonkiness_factor = val;if Engine.is_editor_hint(): emit_changed()
@export_range(-1, 1, 0.1) var eyes_spread_factor: float = 0:
	set(val): eyes_spread_factor = val;if Engine.is_editor_hint(): emit_changed()
@export_range(-1, 1, 0.1) var eyes_tilt_factor: float = 0:
	set(val): eyes_tilt_factor = val;if Engine.is_editor_hint(): emit_changed()
@export_range(-1, 1, 0.1) var eyes_height_factor: float = 0:
	set(val): eyes_height_factor = val;if Engine.is_editor_hint(): emit_changed()

@export var crown_id: String = "":
	set(id): crown_id = id; crown_pscn = load(crown_resource_path(id)) if FileAccess.file_exists(crown_resource_path(id)) else null; if Engine.is_editor_hint(): emit_changed()
var crown_pscn: PackedScene = null:
	set(new_value): crown_pscn = new_value; emit_changed(); if Engine.is_editor_hint(): emit_changed()


func crown_resource_path(id: String):
	return "res://bonki_model/crowns/{id}/{id}_crown.tscn".format({"id":id})

var crowns_and_colors: Dictionary[String, BonkiColors] = {
	"chanterelle": BonkiColors.def([
		Color.from_hsv(0.083, 0.7, 0.8),
		Color.from_hsv(0.125, 0.9, 0.9),
	]),
	"christmas_rose": BonkiColors.def([
		Color.from_hsv(0.506, 0.3, 0.7),
		Color.from_hsv(0.542, 0.4, 0.9),
	]),
	"enoki": BonkiColors.def([
		Color.from_hsv(0.056, 0.6, 0.5),
		Color.from_hsv(0.108, 0.7, 0.6),
	]),
	"yellow_stagshorn": BonkiColors.def([
		Color.from_hsv(0.117, 0.8, 0.5),
		Color.from_hsv(0.156, 1, 0.7),
	]),
	"pincushion_moss": BonkiColors.def([
		Color.from_hsv(0.194, 0.3, 0.3),
		Color.from_hsv(0.278, 0.4, 0.7),
	]),
	"porcini": BonkiColors.def([
		Color.from_hsv(0.101, 0.365, 0.775, 1.0),
		Color.from_hsv(0.098, 0.652, 0.609, 1.0),
	]),
	"kale": BonkiColors.def([
		Color.from_hsv(0.306, 0.3, 0.3),
		Color.from_hsv(0.331, 0.5, 0.7),
	]),
	"cladonia": BonkiColors.def([
		Color.from_hsv(0.344, 0.3, 0.5),
		Color.from_hsv(0.403, 0.4, 0.7),
	]),
}

func get_weighted_blend(colors: Array[Color], weights: Array[float]) -> Color:
	if colors.size() != weights.size() or colors.is_empty():
		push_error("Arrays must be non-empty and of equal length.")
		return Color.BLACK

	var combined_r: float = 0.0
	var combined_g: float = 0.0
	var combined_b: float = 0.0
	var combined_a: float = 0.0
	var total_weight: float = 0.0

	for i in range(colors.size()):
		var weight = weights[i]
		var col = colors[i]
		
		combined_r += col.r * weight
		combined_g += col.g * weight
		combined_b += col.b * weight
		combined_a += col.a * weight
		total_weight += weight

	# Prevent division by zero if all weights are 0
	if total_weight == 0:
		return Color.BLACK

	return Color(
		combined_r / total_weight,
		combined_g / total_weight,
		combined_b / total_weight,
		combined_a / total_weight
	)

func get_random_weighted_blend(colors: Array[Color]) -> Color:
	if colors.is_empty():
		return Color.BLACK
	
	var random_weights: Array[float] = []
	
	# Assign a random influence to each color
	for i in range(colors.size()):
		random_weights.append(randf())
	
	# Use the previous function to calculate the result
	return get_weighted_blend(colors, random_weights)

func randomize():
	# Skip randomization during CI build or in headless mode
	if OS.has_environment("GODOT_CI_BUILD") or DisplayServer.get_name() == "headless":
		return
		
	crown_id = crowns_and_colors.keys()[randi_range(0, crowns_and_colors.size() - 1)]

	var colors_for_type = crowns_and_colors[crown_id].colors

	body_color = get_random_weighted_blend(colors_for_type)
	
	var body_hue := body_color.h

	var eye_hue := body_hue + randf_range(0.1, 0.5)
	if (eye_hue > 1): eye_hue -= 1
	var eye_shadow_hue := eye_hue + randf_range(0, 0.5)
	if (eye_shadow_hue > 1): eye_shadow_hue -= 1

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
	
	var crown_path = crown_resource_path(crown_id)
	print("crown_path")
	print(crown_path)
	crown_pscn = load(crown_path)
	pass

@export_tool_button("Reload crown")
var reload_crown_action: Callable = reload_crown
func reload_crown():
	var old_crown_pscn = crown_pscn
	crown_pscn = null
	crown_pscn = old_crown_pscn
	pass
	

func toJSON():
	return {
		"body_color": body_color.to_html(),
		"eye_shine_color": eye_shine_color.to_html(),
		"eye_shadow_color": eye_shadow_color.to_html(),
		"eye_base_color": eye_base_color.to_html(),
		"wide_stretch_factor": wide_stretch_factor,
		"horn_stretch_factor": horn_stretch_factor,
		"long_stretch_factor": long_stretch_factor,
		"pearness_factor": pearness_factor,
		"tall_stretch_factor": tall_stretch_factor,
		"wonkiness_factor": wonkiness_factor,
		"eyes_spread_factor": eyes_spread_factor,
		"eyes_tilt_factor": eyes_tilt_factor,
		"eyes_height_factor": eyes_height_factor,
		"crown_id": crown_id if crown_id else ""
	}
	
static func fromJSON(json: Dictionary) -> BonkiAppearanceParameters:
	var obs := BonkiAppearanceParameters.new()
	if json.is_empty():
		return obs
	
	# Restore Colors
	if "body_color" in json: obs.body_color = Color(json["body_color"])
	if "eye_shine_color" in json: obs.eye_shine_color = Color(json["eye_shine_color"])
	if "eye_shadow_color" in json: obs.eye_shadow_color = Color(json["eye_shadow_color"])
	if "eye_base_color" in json: obs.eye_base_color = Color(json["eye_base_color"])
	
	# Restore Floats
	obs.wide_stretch_factor = json.get("wide_stretch_factor", 0.0)
	obs.horn_stretch_factor = json.get("horn_stretch_factor", 0.0)
	obs.long_stretch_factor = json.get("long_stretch_factor", 0.0)
	obs.pearness_factor = json.get("pearness_factor", 0.0)
	obs.tall_stretch_factor = json.get("tall_stretch_factor", 0.0)
	obs.wonkiness_factor = json.get("wonkiness_factor", 0.0)
	obs.eyes_spread_factor = json.get("eyes_spread_factor", 0.0)
	obs.eyes_tilt_factor = json.get("eyes_tilt_factor", 0.0)
	obs.eyes_height_factor = json.get("eyes_height_factor", 0.0)
	
	obs.crown_id = json.get("crown_id", "")

		
	return obs
