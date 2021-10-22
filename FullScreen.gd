extends Spatial


func _input(event):
	if event is InputEventKey:
		if event.scancode == KEY_K and event.pressed:
			OS.window_fullscreen = !OS.window_fullscreen
		if event.scancode == KEY_KP_ADD and event.pressed:
			$"DirectionalLight".light_energy += 0.5
		if event.scancode == KEY_KP_SUBTRACT and event.pressed:
			$"DirectionalLight".light_energy -= 0.5
		$"DirectionalLight".light_energy = clamp($"DirectionalLight".light_energy, 1, 10)
