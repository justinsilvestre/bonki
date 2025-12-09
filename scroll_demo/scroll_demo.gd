extends Node3D

func _on_boundary_entered(body: Node3D):
	if body is ScrollBonki:
		body.queue_free()
	pass
