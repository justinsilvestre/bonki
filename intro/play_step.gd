class_name PlayStep

var type: StepType
var label: String = ""

var anim_name: String
var text_content: String
var options: Dictionary[String, Callable]
var action_callback: Callable

enum StepType {
	ANIMATION,
	TEXT,
	TEXT_INPUT,
	CHOICE,
	ACTION
}

func label_with(label: String):
	self.label = label
	return self

static func animation(anim_name: String):
	var step := PlayStep.new()
	step.type = StepType.ANIMATION
	step.anim_name = anim_name
	return step

static func text(text_content: String):
	var step := PlayStep.new()
	step.type = StepType.TEXT
	step.text_content = text_content
	return step

static func choice(text_content: String, options: Dictionary[String, Callable]):
	var step := PlayStep.new()
	step.type = StepType.CHOICE
	step.text_content = text_content
	step.options = options
	return step

static func text_input(text_content: String):
	var step := PlayStep.new()
	step.type = StepType.TEXT_INPUT
	step.text_content = text_content
	return step

static func action(action_callback: Callable):
	var step := PlayStep.new()
	step.type = StepType.ACTION
	step.action_callback = action_callback
	return step
