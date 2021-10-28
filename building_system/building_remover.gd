extends Spatial


var enabled
func _input(event):
	if event is InputEventKey:
		if event.scancode == KEY_Y and event.pressed:
			enabled = !enabled
	
	if event is InputEventMouseMotion:
		pass

