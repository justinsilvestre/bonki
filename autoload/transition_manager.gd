extends Node

const OVERLAY_SCENE := preload("res://ui/transition_overlay.tscn")
const LOADING_SCENE := preload("res://ui/loading_screen.tscn")

const OVERLAY_NODE_PATH_TO_FADE_ANIMATION := "CanvasLayer/FadeAnimationPlayer"
const OVERLAY_NODE_PATH_TO_LOADING_HOST := "CanvasLayer/LoadingHostControl"
const OVERLAY_PATH_TO_FADE_COLOR_RECT := "CanvasLayer/FadeColorRect"

var overlay: Control
var fade_anim: AnimationPlayer
var loading_host: Control
var loading: Control

var _is_busy: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("transition overlay ready")
	overlay = OVERLAY_SCENE.instantiate()
	await get_tree().process_frame
	print("overlay instantiated")
	get_tree().root.add_child.call_deferred(overlay)
	print("add_child called deferred")
	#get_tree().root.add_child(overlay)
	
	await overlay.tree_entered
	print("tree entered")
	
	_set_input_blocking(false)

	# Keep transitions running even if the game is paused later.
	overlay.process_mode = Node.PROCESS_MODE_ALWAYS
	
	loading_host = overlay.get_node(OVERLAY_NODE_PATH_TO_LOADING_HOST) as Control
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func go_to_scene_threaded(scene_path: String, status_text: String = "Loading…") -> void:
	print("go_to_scene_threaded!")
	print("status_text")
	print("_is_busy?")
	print(_is_busy)
	if _is_busy:
		return
	_is_busy = true

	_show_loading(status_text)

	# Start threaded load.
	ResourceLoader.load_threaded_request(scene_path)  # background loading :contentReference[oaicite:13]{index=13}
	var progress := [0.0]

	while true:
		var st := ResourceLoader.load_threaded_get_status(scene_path, progress)
		_update_loading_progress(progress)
		if st == ResourceLoader.THREAD_LOAD_LOADED:
			break
		if st == ResourceLoader.THREAD_LOAD_FAILED or st == ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
			_hide_loading()
			_is_busy = false
			return
		await get_tree().process_frame

	var res := ResourceLoader.load_threaded_get(scene_path)
	if res is PackedScene:
		get_tree().change_scene_to_packed(res) # scene switch :contentReference[oaicite:14]{index=14}

	_hide_loading()
	_is_busy = false
	_set_input_blocking(false)
	
func _show_loading(status_text: String) -> void:
	if loading == null:
		loading = LOADING_SCENE.instantiate()
		loading_host.add_child(loading)
	if loading.has_method("set_status"):
		loading.call("set_status", status_text)
	if loading.has_method("set_progress"):
		loading.call("set_progress", 0.0)

func _hide_loading() -> void:
	if loading != null and is_instance_valid(loading):
		loading.queue_free()
		loading = null

func _update_loading_progress(progress_arr: Array) -> void:
	if loading == null:
		return
	if progress_arr.size() == 0:
		return
	var pct := float(progress_arr[0]) * 100.0
	if loading.has_method("set_progress"):
		loading.call("set_progress", pct)

func _set_input_blocking(blocking: bool) -> void:
	print("blocking input" if blocking else "freeing input")
	#var rect := overlay.get_node(OVERLAY_PATH_TO_FADE_COLOR_RECT) as Control
	var rect := overlay
	if blocking:
		rect.mouse_filter = Control.MOUSE_FILTER_STOP 
	else:
		rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		
func block_input() -> void:
	_set_input_blocking(true)
func free_input() -> void:
	_set_input_blocking(false)
