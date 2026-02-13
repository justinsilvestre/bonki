class_name TextContinuationIndicator

extends Polygon2D

func _ready():
	_start_bouncing()

var fade_tween: Tween

@onready var original_pos := position

var bounce_tween: Tween

func show_indicator():
	# 1. Reset state
	self.modulate.a = 0
	self.show()
	
	# 2. Cancel any existing tween to prevent conflicts
	if fade_tween:
		fade_tween.kill()
		
	# 3. Create a new tween for the sequence
	fade_tween = create_tween()
	
	# Delay for 0.5 seconds, then fade alpha (a) to 1.0 over 0.3 seconds
	fade_tween.tween_interval(1)
	fade_tween.tween_property(self, "modulate:a", 0.5, 0.3)
	
	_start_bouncing()

func hide_indicator():
	if fade_tween:
		fade_tween.kill()
	if bounce_tween:
		bounce_tween.kill()
	self.hide()

func _start_bouncing():
	bounce_tween = create_tween().set_loops()
	bounce_tween.tween_property(self, "position:x", original_pos.x, 0.6).set_trans(Tween.TRANS_SINE)
	bounce_tween.tween_property(self, "position:x", original_pos.x + 10, 0.6).set_trans(Tween.TRANS_SINE)
