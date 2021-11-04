extends Node


func draw_line(immediate_geo: ImmediateGeometry, start_position, end_position, color = Color.white):
	immediate_geo.set_color(color)
	immediate_geo.add_vertex(start_position)
	immediate_geo.set_color(color)
	immediate_geo.add_vertex(end_position)

func draw_triangle_with_uv(immediate_geo: ImmediateGeometry, v0: Vector3, uv0: Vector2, v1: Vector3, uv1: Vector2, v2: Vector3, uv2: Vector2, color: Color):
	immediate_geo.set_color(color)
	immediate_geo.set_uv(uv0)
	immediate_geo.add_vertex(v0)
	immediate_geo.set_color(color)
	immediate_geo.set_uv(uv1)
	immediate_geo.add_vertex(v1)
	immediate_geo.set_color(color)
	immediate_geo.set_uv(uv2)
	immediate_geo.add_vertex(v2)

func draw_triangle(immediate_geo: ImmediateGeometry, v0, v1, v2, color):
	draw_triangle_with_uv(immediate_geo,
		v0,
		Vector2(v0.x, v0.z),
		v1,
		Vector2(v1.x, v1.z),
		v2,
		Vector2(v2.x, v2.z),
		color
	)

func draw_empty_circle(immediate_geometry, circle_center, circle_radius, color = Color.white):
	immediate_geometry.begin(Mesh.PRIMITIVE_LINE_LOOP)
	for i in range(int(20)):
		var rotation = float(i) / 20 * TAU
		var position = Vector3(0, 0, circle_radius)
#		print("working?")
		immediate_geometry.set_color(color)
		immediate_geometry.add_vertex(position.rotated(Vector3.UP, rotation) + circle_center)
	immediate_geometry.set_color(Color.white)
	immediate_geometry.end()


func quadratic_bezier(p0: Vector3, p1: Vector3, p2: Vector3, t: float):
	var q0 = p0.linear_interpolate(p1, t)
	var q1 = p1.linear_interpolate(p2, t)
	return q0.linear_interpolate(q1, t)

func draw_curve(immediate_geo: ImmediateGeometry, p0: Vector3, mp: Vector3, p1: Vector3, color: Color, resolution: int = 10):
	var last_point = p0
	for t in range(resolution):
		immediate_geo.set_color(color)
		immediate_geo.add_vertex(last_point)
		immediate_geo.set_color(color)
		last_point = quadratic_bezier(p0, mp, p1, t/float(resolution))
		immediate_geo.add_vertex(last_point)

	immediate_geo.set_color(color)
	immediate_geo.add_vertex(last_point)
	immediate_geo.set_color(color)
	immediate_geo.add_vertex(p1)


func draw_curve_triangles(immediate_geo: ImmediateGeometry, p0: Vector3, mp: Vector3, p1: Vector3, center: Vector3, color: Color, resolution: int = 10):
	var last_point = p0
	for t in range(resolution+1):
		var new_point = quadratic_bezier(p0, mp, p1, t/float(resolution))
		draw_triangle(immediate_geo,
			last_point,
			new_point,
			center,
			color)
		last_point = new_point

func draw_box(immediate_geo: ImmediateGeometry, position: Vector3, extents: Vector3, color: Color = Color.skyblue):
#	immediate_geo.add_vertex(Vector3(position.x+extents.x, position.y, position.z+extents.z))
	immediate_geo.begin(Mesh.PRIMITIVE_LINES)
	var aabb = AABB(-extents+position, extents*2)
	for i in range(12):
		for point in AABBUtils.get_edge(aabb, i):
			immediate_geo.set_color(color)
			immediate_geo.add_vertex(point)
#	var v0 = Vector3(-extents.x, -extents.y, extents.z) + position
#	var v1 = Vector3(extents.x, -extents.y, extents.z) + position
#	var v2 = Vector3(extents.x, -extents.y, -extents.z) + position
#	var v3 = Vector3(-extents.x, -extents.y, -extents.z) + position 
#	var v4 = Vector3(-extents.x, extents.y, extents.z) + position
#	var v5 = Vector3(extents.x, extents.y, extents.z) + position
#	var v6 = Vector3(extents.x, extents.y, -extents.z) + position
#	var v7 = Vector3(-extents.x, extents.y, -extents.z) + position
#
#	var vertices = [
#		v0, v1, v2, v0, 
#		v7, v4, v0, v3,
#		v4, v5, v1, v0, 
#		v6, v7, v3, v2,
#		v5, v6, v2, v1,
#		v7, v6, v5, v4,
#	]
#	var up = Vector3.UP
#	var down = Vector3.DOWN
#	var front = Vector3.FORWARD
#	var back = Vector3.BACK
#	var left = Vector3.LEFT
#	var right = Vector3.RIGHT
#
#	var normals = [
#		down, down, down, down,
#		left, left, left, left,
#		front, front, front, front,
#		back, back, back, back,
#		right, right, right, right,
#		up, up, up, up
#	]
#	for i in range(24):
#		immediate_geo.set_color(color)
#		immediate_geo.set_normal(normals[i])
#		immediate_geo.add_vertex(vertices[i])
#
#	for i in range(6):
#		immediate_geo
	immediate_geo.end()

func draw_box_with_aabb(immediate_geo: ImmediateGeometry, aabb: AABB, offset: Vector3, color: Color = Color.skyblue):
#	immediate_geo.begin(Mesh.PRIMITIVE_LINES)
#	for i in range(12):
#		for point in AABBUtils.get_edge(aabb, i):
#			immediate_geo.set_color(color)
#			immediate_geo.add_vertex(point)
#	immediate_geo.end()
	var path = []

	#bottom
	path.append(aabb.get_endpoint(0))
	path.append(aabb.get_endpoint(1))
	path.append(aabb.get_endpoint(1))
	path.append(aabb.get_endpoint(5))
	path.append(aabb.get_endpoint(5))
	path.append(aabb.get_endpoint(4))
	path.append(aabb.get_endpoint(4))
	path.append(aabb.get_endpoint(0))
	#top
	path.append(aabb.get_endpoint(7))
	path.append(aabb.get_endpoint(6))
	path.append(aabb.get_endpoint(7))
	path.append(aabb.get_endpoint(3))
	path.append(aabb.get_endpoint(2))
	path.append(aabb.get_endpoint(3))
	path.append(aabb.get_endpoint(2))
	path.append(aabb.get_endpoint(6))
	#sides
	path.append(aabb.get_endpoint(0))
	path.append(aabb.get_endpoint(2))
	path.append(aabb.get_endpoint(1))
	path.append(aabb.get_endpoint(3))
	path.append(aabb.get_endpoint(4))
	path.append(aabb.get_endpoint(6))
	path.append(aabb.get_endpoint(5))
	path.append(aabb.get_endpoint(7))


	var temp_path = []
	for item in path:
		temp_path.append(item - offset)
	path = temp_path
	immediate_geo.begin(Mesh.PRIMITIVE_LINES)
	for i in range(0, path.size()-1,2):
		immediate_geo.add_vertex(path[i])
		immediate_geo.add_vertex(path[i+1])
	immediate_geo.end()
