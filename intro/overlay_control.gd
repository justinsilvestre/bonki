extends Control

signal step_finished
signal choice_selected(index: int)
signal text_submitted(input_text: String)

@onready var text_label: RichTextLabel = $TextPanel/RichTextLabel
@onready var choice_container: VBoxContainer = $Choice_VBoxContainer
@onready var input_container = $Input_VBoxContainer
@onready var input_field = $Input_VBoxContainer/LineEdit
@onready var confirm_button = $Input_VBoxContainer/Button

var current_step_type = null

func show_text(new_text: String):
	_reset_ui()
	current_step_type = "text"
	text_label.text = new_text
	show() # Make sure the UI is visible

func _gui_input(event):
	# Detect mouse click or touch tap
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT and current_step_type == "text":
		accept_event()
		hide()
		step_finished.emit() # Tell the manager we are done

func _ready() -> void:
	hide()

	# Connect the confirm button
	confirm_button.pressed.connect(_on_confirm_pressed)
	# Optional: Allow pressing "Enter" inside the box to confirm
	input_field.text_submitted.connect(_on_confirm_pressed_from_field)
	
func show_choices(prompt_text: String, options: Array):
	_reset_ui()
	current_step_type = "choice"
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

func show_text_input(prompt_text: String, default_text: String = ""):
	_reset_ui()
	current_step_type = "text_input"
	text_label.text = prompt_text
	
	# Setup input field
	input_field.text = default_text
	input_container.show()
	input_field.grab_focus() # So user can type immediately
	show()

func _reset_ui():
	choice_container.hide()
	input_container.hide()
	
func _on_confirm_pressed():
	if input_field.text.strip_edges() == "":
		return # Prevent empty names
		
	text_submitted.emit(input_field.text)
	input_container.hide()

# Helper to handle the 'text_submitted' signal from LineEdit (which passes text argument)
func _on_confirm_pressed_from_field(_text):
	_on_confirm_pressed()
