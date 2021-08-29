extends MeshInstance

#func _render_road(network: RoadNetwork):
##	var arr = []
##	arr.resize(ArrayMesh.ARRAY_MAX)
##	arr[ArrayMesh.ARRAY_VERTEX] = PoolVector3Array()
##	arr[ArrayMesh.ARRAY_INDEX] = PoolIntArray()
##	arr[ArrayMesh.ARRAY_TEX_UV] = PoolVector2Array()
##	arr[ArrayMesh.ARRAY_NORMAL] = PoolVector3Array()
#
#	var surface_tool = SurfaceTool.new()
#	var vertex_index = 0
#
#	var changed = false
#	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
#	var spacing = 0.1
#	for connection in network.network.values():
#		var points = connection.get_points(spacing, 1)
##		arr[ArrayMesh.ARRAY_VERTEX].resize(vertex_index+(points.size() * 2))
##		arr[ArrayMesh.ARRAY_INDEX].resize(triangle_index+(2 * (points.size() - 1) * 3))
##		arr[ArrayMesh.ARRAY_TEX_UV].resize(vertex_index+(points.size() * 2))
#		vertex_index = calculate_road_mesh_vertices(points, surface_tool, vertex_index, connection.width, spacing*10)[0]
#		if connection.start_position.connections.size() > 0:
#			pass
#		changed = true
#	if changed:
#		mesh = ArrayMesh.new()
#
#		surface_tool.commit(mesh)
#
#
#func calculate_road_mesh_vertices(points, surface_tool: SurfaceTool, vertex_index, road_width = 10, uv_scale = 10, use_ping_pong_v = true):
#
#	uv_scale = uv_scale * points.size() * 0.05
#	var completion_percentage = 0
#
#	for i in points.size():
#
#		var forward = Vector3.ZERO
#		if i < points.size() - 1:
#			forward += points[i+1] - points[i]
#		if i > 0:
#			forward += points[i] - points[i-1]
#		forward = forward.normalized()
#
#		completion_percentage = i / float(points.size() - 1)
#		var v
#		if use_ping_pong_v:
#			v = 1 - abs(2 * completion_percentage - 1)
#		else:
#			v = completion_percentage
#
##		uvs[vertex_index] = Vector2(v * uv_scale, -0.1)
##		uvs[vertex_index+1] = Vector2(v * uv_scale, 1.1)
#
#		var left = Vector3(-forward.z, forward.y, forward.x)
#
#		surface_tool.add_uv(Vector2(v * uv_scale, -0.1))
#		surface_tool.add_normal(Vector3.UP)
#		surface_tool.add_vertex(points[i] + left * road_width * 0.5)
#		surface_tool.add_uv(Vector2(v * uv_scale, 1.1))
#		surface_tool.add_normal(Vector3.UP)
#		surface_tool.add_vertex(points[i] + -left * road_width * 0.5)
#
#
#		if i < points.size() - 1:
#			surface_tool.add_index(vertex_index + 0)
#			surface_tool.add_index(vertex_index + 1)
#			surface_tool.add_index(vertex_index + 2)
#
#			surface_tool.add_index(vertex_index + 1)
#			surface_tool.add_index(vertex_index + 3)
#			surface_tool.add_index(vertex_index + 2)
#
#		vertex_index += 2
#	return [vertex_index]
#
const RoadIntersection = RoadNetwork.RoadIntersection
const RoadSegment = RoadNetwork.RoadSegment


var intersection_1 = null

var surface_tool = SurfaceTool.new()

var rendering_mode = Mesh.PRIMITIVE_TRIANGLES

func _render_road(road_network):
	surface_tool.clear()
#	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	surface_tool.begin(rendering_mode)
	# sort the angles
	for intersection in road_network.intersections:
		if intersection.connections.size() > 1:
			var _sorter = Sorter.new(self, "sort_by_angle", intersection.connections, [intersection])
#	road_network.draw(Color.white, Color.aqua)
	var vertex_array = {}
	for intersection in road_network.intersections:
		if !intersection.connections:
			draw_filled_circle(surface_tool, intersection.road_network_info.width/2, intersection.position)
			continue
#			draw_filled_circle(surface_tool, 1, intersection.position)
		var v1dict = draw_intersection(intersection)
		
		draw_complete_intersection(surface_tool, intersection, v1dict[0], v1dict[1])
#		print(v1dict[0], v1dict[1])
		vertex_array[intersection] = v1dict
		
	
#	var connection_index = 0
#	print(road_network.network.values().size())
#	print(road_network.network.keys())
	for connection in road_network.network.values():
		var start_dict = vertex_array[connection.start_position]
		var end_dict = vertex_array[connection.end_position]
		
		var start_connection_intersection = start_dict[0][connection]
		var end_connection_intersection = end_dict[0][connection]
		
		draw_connection(surface_tool, start_connection_intersection, end_connection_intersection)
	
	mesh = surface_tool.commit()

func compute_intersection(p0, angle0, p1, angle1, end_radius) -> Vector3:
	var midpoint = (p0+p1)/2.0
	var arc = abs(angle0 - angle1)
	var midangle = (angle0 + angle1)/2.0
	# print("angle: ", midangle, ", distance: ", midpoint.distance_to(vert0.v1))
	var offset = Vector3()
	if not is_zero_approx(arc):
		offset = Vector3(sin(midangle), 0, cos(midangle))*midpoint.distance_to(p0)/tan(arc/2)
	else:
		offset = Vector3(sin(midangle), 0, cos(midangle))*midpoint.distance_to(p0) * end_radius
	# print("offset: ", offset)
	return midpoint - offset


func compute_edge_intersection(vert0, vert1, end_radius) -> Vector3:
	return compute_intersection(vert0.v1, vert0.angle, vert1.v2, vert1.angle, end_radius)

func draw_intersection(intersection: RoadIntersection):
	# DrawingUtils.draw_empty_circle($ImmediateGeometry, intersection.position, 0.5, Color.lightcyan)

	var intersection_verts = {}
	var start_points = []
	for connection in intersection.connections:
		if connection.road_network_info.width != 0:
			var vert = {}
			var intersection_bound_for = connection.start_position if intersection == connection.end_position else connection.end_position
			var direction = intersection.direction_to(intersection_bound_for)
			var start_point = intersection.position
			if intersection.connections.size() > 1:
				start_point += direction * intersection.road_network_info.length
#				print("anything wrong?", intersection, intersection_bound_for)
			start_points.append(start_point)
#			DrawingUtils.draw_empty_circle($ImmediateGeometry, start_point, 0.25, Color.yellow)
			vert["start_position"] = start_point
			var left = Vector3(-direction.z, direction.y, direction.x)
			left = left.normalized()
			var v1 = start_point + left * connection.road_network_info.width * 0.5
			var v2 = start_point + -left * connection.road_network_info.width * 0.5
			vert["v1"] = v1
			vert["v2"] = v2
			vert["angle"] = atan2(direction.x, direction.z)
#			DrawingUtils.draw_empty_circle($ImmediateGeometry, v1, 0.125, Color.red)
#			DrawingUtils.draw_empty_circle($ImmediateGeometry, v2, 0.125, Color.green)
			intersection_verts[connection] = vert

	var connections = intersection.connections
	var mid_points = []
	for connection_idx in connections.size()-1:
		if connections[connection_idx].road_network_info.width != 0:
			var point = compute_edge_intersection(intersection_verts[connections[connection_idx]], intersection_verts[connections[connection_idx+1]], intersection.road_network_info.end_radius)
#			DrawingUtils.draw_empty_circle($ImmediateGeometry, point, 0.125, Color.bisque)
			mid_points.append(point)
	if connections.size():
		var point = compute_edge_intersection(intersection_verts[connections[-1]], intersection_verts[connections[0]], intersection.road_network_info.end_radius)
#	DrawingUtils.draw_empty_circle($ImmediateGeometry, point, 0.125, Color.orange)
		mid_points.append(point)
		
	return [intersection_verts, mid_points]

func draw_connection(_surface_tool: SurfaceTool, i1: Dictionary, i2: Dictionary, resolution: int = 20):
	var last_v1 = i1.v1
	var last_v2 = i1.v2
	for i in resolution+1:
		var t = i/float(resolution)
		var v1 = lerp(i1.v2, i2.v1, t)
		var v2 = lerp(i1.v1, i2.v2, t)
		draw_triangle(_surface_tool,
			last_v1,
			v1,
			v2)
		draw_triangle(_surface_tool, 
			last_v2,
			v1,
			last_v1)
		last_v1 = v2
		last_v2 = v1
#	draw_triangle(_surface_tool,
#		i1.v1,
#		i2.v1,
#		i2.v2)
#	draw_triangle(_surface_tool,
#		i1.v2,
#		i2.v1,
#		i1.v1)

func draw_complete_intersection(_surface_tool, intersection, vertex_data, mid_point_data):
	if intersection.connections.size() == 1:
		var v1 = vertex_data[vertex_data.keys()[0]].v1
		var v2 = vertex_data[vertex_data.keys()[0]].v2
		var offset_midpoint =  mid_point_data[0]
		var real_midpoint = (v1 + v2) / 2.0
		var offset = offset_midpoint - real_midpoint
		draw_curve_triangles(_surface_tool, v1, v1 + offset, offset_midpoint, real_midpoint)
		draw_curve_triangles(_surface_tool, offset_midpoint, v2 + offset, v2, real_midpoint)
	elif intersection.connections.size() > 1:
		var vertex0 = vertex_data[vertex_data.keys()[0]]
		var midpoint0 = (vertex0.v1 + vertex0.v2) / 2.0
		var vertex1 = vertex_data[vertex_data.keys()[1]]
		var midpoint1 = (vertex1.v1 + vertex1.v2) / 2.0
		
		var road_center_intersection = compute_intersection(midpoint0, vertex0.angle, midpoint1, vertex1.angle, intersection.road_network_info.end_radius)
		var intersection_center = quadratic_bezier(midpoint0, road_center_intersection, midpoint1, 0.5)

		var number_of_connections = intersection.connections.size()
		for connection_idx in number_of_connections:
			if intersection.connections[connection_idx].road_network_info.width != 0:
				draw_curve_triangles(_surface_tool,
					vertex_data[vertex_data.keys()[connection_idx]].v1,
					mid_point_data[connection_idx],
					vertex_data[vertex_data.keys()[(connection_idx+1) % number_of_connections]].v2,
					intersection_center)
				var p0 = vertex_data[vertex_data.keys()[connection_idx]].v2
				var p1 = vertex_data[vertex_data.keys()[connection_idx]].v1
				draw_triangle(
					_surface_tool,
					p0,
					p1,
					intersection_center
				)

	# DrawingUtils.draw_line($ImmediateGeometry, vertex_data[-1].v1, mid_point_data[-1], Color.red)
	# DrawingUtils.draw_line($ImmediateGeometry, vertex_data[0].v2, mid_point_data[-1], Color.red)

class Sorter:
	var extra_params = []
	var array
	var object: Object
	var function: String
	
	func _init(_object, _function, _array, _extra_params):
		self.object = _object
		self.function = _function
		self.extra_params = _extra_params
		self.array = _array
		self.array.sort_custom(self, "sort")
	
	func get_array():
		return array
	
	func sort(a, b):
		return object.callv(function, [a, b] + extra_params)
		
func sort_by_angle(a, b, origin):
	var a_position = a.start_position.position if a.end_position == origin else a.end_position.position
	var b_position = b.start_position.position if b.end_position == origin else b.end_position.position
	var a_offset = a_position - origin.position
	var b_offset = b_position - origin.position

	var angle_1 = atan2(a_offset.x, a_offset.z)
	var angle_2 = atan2(b_offset.x, b_offset.z)

	if angle_1 > angle_2:
		return true
	
	if angle_1 < angle_2:
		return false

	return a_offset.length_squared() > b_offset.length_squared()
			

func draw_triangle_with_uv(_surface_tool: SurfaceTool, v0: Vector3, uv0: Vector2, v1: Vector3, uv1: Vector2, v2: Vector3, uv2: Vector2, color: Color = Color()):
	_surface_tool.add_color(color)
	_surface_tool.add_uv(uv0)
	_surface_tool.add_normal(Vector3.UP)
	_surface_tool.add_vertex(v0)
	_surface_tool.add_color(color)
	_surface_tool.add_uv(uv1)
	_surface_tool.add_normal(Vector3.UP)
	_surface_tool.add_vertex(v1)
	_surface_tool.add_color(color)
	_surface_tool.add_uv(uv2)
	_surface_tool.add_normal(Vector3.UP)
	_surface_tool.add_vertex(v2)

func draw_triangle(_surface_tool: SurfaceTool, v0: Vector3, v1: Vector3, v2: Vector3, color: Color = Color()):
		draw_triangle_with_uv(_surface_tool,
		v0,
		Vector2(v0.x, v0.z),
		v1,
		Vector2(v1.x, v1.z),
		v2,
		Vector2(v2.x, v2.z),
		color
	)

func draw_curve_triangles(_surface_tool: SurfaceTool, p0: Vector3, mp: Vector3, p1: Vector3, center: Vector3, color: Color = Color(), resolution: int = 20):
	var last_point = p0
	for t in range(resolution+1):
		var new_point = quadratic_bezier(p0, mp, p1, t/float(resolution))
		draw_triangle(_surface_tool,
			last_point,
			new_point,
			center,
			color)
		last_point = new_point

func quadratic_bezier(p0: Vector3, p1: Vector3, p2: Vector3, t: float):
	var q0 = p0.linear_interpolate(p1, t)
	var q1 = p1.linear_interpolate(p2, t)
	return q0.linear_interpolate(q1, t)

func draw_filled_arc(_surface_tool: SurfaceTool, radius: float, center: Vector3, resolution: int = 64, start_angle: float = 0, end_angle: float = 360):
	var angular_segment = resolution
	_surface_tool.add_normal(Vector3.UP)
	_surface_tool.add_vertex(center)
	
	for i in range(angular_segment+1):
		var t = i / float(angular_segment)
		var angle = deg2rad(start_angle + i * (end_angle-start_angle) / float(angular_segment) - 90)
		var position_outer = Vector3(0, 0, radius)
		_surface_tool.add_normal(Vector3.UP)
		_surface_tool.add_vertex(position_outer.rotated(Vector3.UP, angle)+center)
	
	for i in range(angular_segment):
		
		_surface_tool.add_index(0)
		_surface_tool.add_index(i + 2)
		_surface_tool.add_index(i + 1)
		

func draw_filled_circle(_surface_tool: SurfaceTool, radius: float, center: Vector3, resolution: int = 64):
	draw_filled_arc(_surface_tool, radius, center, resolution)

func _on_RoadNetwork_graph_changed():
	_render_road(get_parent())

func update():
	_render_road(get_parent())

func _input(event):
	if event is InputEventKey:
		if event.scancode == KEY_K:
			rendering_mode = Mesh.PRIMITIVE_TRIANGLES
			_render_road(get_parent())
		elif event.scancode == KEY_L:
			rendering_mode = Mesh.PRIMITIVE_LINES
			_render_road(get_parent())
