extends Control

signal step_finished

@onready var text_label: RichTextLabel = $TextPanel/RichTextLabel
func show_text(new_text: String):
	text_label.text = new_text
	show() # Make sure the UI is visible

func _gui_input(event):
	# Detect mouse click or touch tap
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		accept_event()
		hide()
		step_finished.emit() # Tell the manager we are done
