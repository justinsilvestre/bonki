extends Control

signal step_finished
signal choice_selected(index: int)

@onready var text_label: RichTextLabel = $TextPanel/RichTextLabel
@onready var choice_container: VBoxContainer = $Choice_VBoxContainer

func show_text(new_text: String):
	text_label.text = new_text
	show() # Make sure the UI is visible

func _gui_input(event):
	# Detect mouse click or touch tap
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		accept_event()
		hide()
		step_finished.emit() # Tell the manager we are done

func _ready() -> void:
	hide()
	
func show_choices(prompt_text: String, options: Array):
	text_label.text = prompt_text
	show()
	
	# 1. Clear old buttons
	for child in choice_container.get_children():
		child.queue_free()
	
	# 2. Create new buttons
	for i in range(options.size()):
		var btn = Button.new()
		btn.text = options[i]
		choice_container.add_child(btn)
		# Connect click to our signal, passing the index 'i'
		btn.pressed.connect(func(): choice_selected.emit(i))
		
	choice_container.show()
