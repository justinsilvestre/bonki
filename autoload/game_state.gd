extends Node

const SAVE_PATH := "user://save.cfg"
const SECTION := "progress"
const KEY_SEEN_INTRO := "seen_intro"

var seen_intro: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_load()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func process() -> void:
	pass

func mark_intro_seen() -> void:
	seen_intro = true
	_save()

func _load() -> void:
	var cfg := ConfigFile.new()
	var err := cfg.load(SAVE_PATH)
	if err != OK:
		seen_intro = false
		return
	seen_intro = bool(cfg.get_value(SECTION, KEY_SEEN_INTRO, false))

func _save() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value(SECTION, KEY_SEEN_INTRO, seen_intro)
	cfg.save(SAVE_PATH)
