extends SurfaceTool
class_name MeshDrawer

func draw_triangle_with_uv(v0: Vector3, uv0: Vector2, v1: Vector3, uv1: Vector2, v2: Vector3, uv2: Vector2, color: Color = Color()):
	add_color(color)
	add_uv(uv0)
	add_normal(Vector3.UP)
	add_vertex(v0)
	add_color(color)
	add_uv(uv1)
	add_normal(Vector3.UP)
	add_vertex(v1)
	add_color(color)
	add_uv(uv2)
	add_normal(Vector3.UP)
	add_vertex(v2)

func draw_triangle(v0: Vector3, v1: Vector3, v2: Vector3, color: Color = Color()):
		draw_triangle_with_uv(v0,
		Vector2(0, 0),
		v1,
		Vector2(0, 1),
		v2,
		Vector2(1, 0),
		color
	)

func draw_curve_triangles(p0: Vector3, mp: Vector3, p1: Vector3, center: Vector3, color: Color = Color.white, resolution: int = 20):
	var last_point = p0
	for t in range(resolution+1):
		var new_point = _quadratic_bezier(p0, mp, p1, t/float(resolution))
		draw_triangle(last_point,
			new_point,
			center,
			color)
		last_point = new_point

func _quadratic_bezier(p0: Vector3, p1: Vector3, p2: Vector3, t: float):
	var q0 = p0.linear_interpolate(p1, t)
	var q1 = p1.linear_interpolate(p2, t)
	return q0.linear_interpolate(q1, t)

func draw_filled_arc(radius: float, center: Vector3, resolution: int = 64, start_angle: float = 0, end_angle: float = 360):
	var angular_segment = resolution

	var position_outer = Vector3(0, 0, radius)
	var arc_step = (end_angle-start_angle) / float(angular_segment)

	for i in range(angular_segment):
		var angle1 = deg2rad(start_angle + i * arc_step - 90)
		var angle2 = deg2rad(start_angle + ((i+1) % angular_segment) * arc_step - 90)
		add_normal(Vector3.UP)
		add_vertex(center)
		add_normal(Vector3.UP)
		add_vertex(position_outer.rotated(Vector3.UP, angle2)+center)
		add_normal(Vector3.UP)
		add_vertex(position_outer.rotated(Vector3.UP, angle1)+center)
		

func draw_filled_circle(radius: float, center: Vector3, resolution: int = 64):
	draw_filled_arc(radius, center, resolution)

