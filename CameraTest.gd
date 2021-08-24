extends Spatial


func _process(delta):
	if Input.is_key_pressed(KEY_Q):
		rotate_y(deg2rad(10))
	if Input.is_key_pressed(KEY_E):
		rotate_y(deg2rad(-10))
	if Input.is_key_pressed(KEY_R):
		$Spatial.rotate_x(deg2rad(10))
	if Input.is_key_pressed(KEY_F):
		$Spatial.rotate_x(deg2rad(-10))
	if Input.is_key_pressed(KEY_W):
		translate(Vector3(0, 0, -1)/2)
	if Input.is_key_pressed(KEY_S):
		translate(Vector3(0, 0, 1)/2)
	if Input.is_key_pressed(KEY_A):
		translate(Vector3(-1, 0, 0)/2)
	if Input.is_key_pressed(KEY_D):
		translate(Vector3(1, 0, 0)/2)
	
