extends Node


const LOADING_SCREEN_SCENE := preload("res://loading_screen.tscn")

var _loading_ui: Control
var _target_path: String


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func load_scene_with_loading(path: String) -> void:
	_target_path = path

	# Show loading UI
	_loading_ui = LOADING_SCREEN_SCENE.instantiate()
	get_tree().root.add_child(_loading_ui)

	# Start its animation if present
	var anim := _loading_ui.get_node_or_null("Anim")
	if anim:
		anim.play("loading_loop")

	# Start threaded request
	ResourceLoader.load_threaded_request(_target_path)
	set_process(true)

func _process(_delta: float) -> void:
	var status := ResourceLoader.load_threaded_get_status(_target_path)
	if status == ResourceLoader.THREAD_LOAD_LOADED:
		var res := ResourceLoader.load_threaded_get(_target_path)
		if _loading_ui:
			_loading_ui.queue_free()
		set_process(false)
		get_tree().change_scene_to_packed(res)
	elif status == ResourceLoader.THREAD_LOAD_FAILED:
		if _loading_ui:
			_loading_ui.queue_free()
		set_process(false)
		push_error("Failed to load: %s" % _target_path)
