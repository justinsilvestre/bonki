class_name BonkiColors

extends Node

var colors: Array[Color]

static func def(colors: Array[Color]) -> BonkiColors:
	var bonki_colors = new()
	bonki_colors.colors = colors
	return bonki_colors
