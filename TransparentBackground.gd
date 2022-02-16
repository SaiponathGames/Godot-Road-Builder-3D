extends Node


func _ready():
	get_tree().get_root().transparent_bg = true
	OS.window_maximized = true
	OS.window_borderless = true
#	get_tree().get_root().set_disable_input(true)
	var polygon = PoolVector2Array([Vector2(0, 0), Vector2(1920, 0), Vector2(1920, 1080), Vector2(0, 1080)])
	OS.set_window_mouse_passthrough(polygon)
