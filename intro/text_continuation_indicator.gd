extends Polygon2D

func _ready():
	var tween = create_tween().set_loops()
	# Moves the arrow down 10 pixels, then back up, forever
	tween.tween_property(self, "position:x", position.x + 10, 0.6).set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "position:x", position.x, 0.6).set_trans(Tween.TRANS_SINE)
