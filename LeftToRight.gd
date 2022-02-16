extends Node2D


func _process(delta):
	var viewport_size = get_viewport_rect()
	position.x = wrapf(position.x+300*delta, viewport_size.position.x, viewport_size.end.x)
