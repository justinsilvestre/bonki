extends Control

@onready var bar: TextureProgressBar = $VBoxContainer/TextureProgressBar
@onready var label: RichTextLabel = $RichTextLabel

func set_progress(percent: float) -> void:
	bar.value = clamp(percent, 0.0, 100.0)

func set_status(text: String) -> void:
	label.text = text
