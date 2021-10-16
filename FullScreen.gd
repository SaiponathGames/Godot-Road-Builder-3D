extends Spatial


func _input(event):
	if event is InputEventKey:
		if event.scancode == KEY_K and event.pressed:
			OS.window_fullscreen = !OS.window_fullscreen
