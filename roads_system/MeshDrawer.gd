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

func draw_curved_quad(p0: Vector3, mp0: Vector3, p1: Vector3, p2: Vector3, mp1: Vector3, p3: Vector3, color: Color = Color.white, resolution: int = 20):
	var a_last = p0
	var b_last = p2
	
	for i in range(1, resolution + 1):
		var t = i / float(resolution)
		
		var a_new = _quadratic_bezier(p0, mp0, p1, t)
		var b_new = _quadratic_bezier(p2, mp1, p3, t)
		
		draw_triangle(a_last, b_last, a_new, color)
		draw_triangle(a_new, b_last, b_new, color)
		
		a_last = a_new
		b_last = b_new

func draw_curved_quad_w(p0, mp0, p1, ldir, wid, up: Vector3 = Vector3.UP, color: Color = Color.white, res = 10, delta = 0.05):
	var a_last = p0 + -ldir * wid
	var b_last = p0 + ldir * wid
	var p_last = p0
	
	for i in range(1, res + 1):
		var t = i / float(res)
		
		var tangent = 2 * (1 - t) * (mp0 - p0) + 2 * t * (p1 - mp0)
		var dir = tangent.normalized()
		var raw_extrude = dir.cross(up)
		if raw_extrude.length_squared() > 0.001:
			var new_ldir = raw_extrude.normalized()
			if new_ldir.dot(ldir) < 0.0:
				new_ldir = -new_ldir
			ldir = new_ldir
		
		var p_new = _quadratic_bezier(p0, mp0, p1, t)
		var a_new = p_new + -ldir * wid
		var b_new = p_new + ldir * wid
		
		
		
		
		draw_triangle(a_last, b_last, a_new, color)
		draw_triangle(a_new, b_last, b_new, color)
		
		
		p_last = p_new
		a_last = a_new
		b_last = b_new
		 

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

