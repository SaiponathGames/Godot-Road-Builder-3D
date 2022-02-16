extends MeshInstance

export(NodePath) var immediate_geometry_node_path
onready var immediate_geometry_node = get_node(immediate_geometry_node_path)

export var can_draw_lanes = false
var surface_tool = MeshDrawer.new()

var rendering_mode = Mesh.PRIMITIVE_TRIANGLES

var count = 0

func _render_road(road_network):
	count+=1
#	prints(name, count)
	immediate_geometry_node.clear()
	surface_tool.clear()
#	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	surface_tool.begin(rendering_mode)
	# sort the angles
	for intersection in road_network.intersections:
		if intersection.connections.size() > 1:
			var _sorter = CustomSorter.new(self, "sort_by_angle", [intersection])
			_sorter.sort(intersection.connections)
			intersection.update_visiblity_connections()
#	road_network.draw(Color.white, Color.aqua)
	var vertex_array = {}
	for intersection in road_network.intersections:
		if !intersection.connections:
			if intersection.visible:
				surface_tool.draw_filled_circle(intersection.road_network_info.segment_width/2, intersection.position)
		else:
			var v1dict = draw_intersection(intersection)
		
			if intersection.visible:
				draw_complete_intersection(surface_tool, intersection, v1dict[0], v1dict[1])
			vertex_array[intersection] = v1dict
		
	for connection in road_network.network.values():
		if !(connection.start_position.visible or connection.end_position.visible) or !connection.visible:
			continue
		if connection is RoadSegmentBezier:
			var start_dict = vertex_array[connection.start_position]
			var middle_dict = vertex_array[connection.middle_position]
			var end_dict = vertex_array[connection.end_position]
			
			var start_connection_intersection = start_dict[0][connection]
			var middle_connection_intersection = middle_dict[0][connection]
			var end_connection_intersection = end_dict[0][connection]
			draw_bezier_connection(surface_tool, start_connection_intersection, middle_connection_intersection, end_connection_intersection)
			continue
		var start_dict = vertex_array[connection.start_position]
		var end_dict = vertex_array[connection.end_position]
		
		var start_connection_intersection = start_dict[0][connection]
		var end_connection_intersection = end_dict[0][connection]
		draw_connection(surface_tool, start_connection_intersection, end_connection_intersection)
		if can_draw_lanes:
			$ImmediateGeometry.clear()
			draw_lanes(surface_tool, connection)

	mesh = surface_tool.commit()

func compute_intersection_values(p0, angle0, p1, angle1, end_radius) -> Vector3:
	var midpoint = (p0+p1)/2.0
	var arc = abs(angle0 - angle1)
	var midangle = (angle0 + angle1)/2.0
	var offset = Vector3()
	if not is_zero_approx(arc):
		offset = Vector3(sin(midangle), 0, cos(midangle))*midpoint.distance_to(p0)/tan(arc/2)
	else:
		offset = Vector3(sin(midangle), 0, cos(midangle))*midpoint.distance_to(p0) * end_radius
	return midpoint - offset


func compute_edge_intersection(vert0, vert1, end_radius) -> Vector3:
	return compute_intersection_values(vert0.v1, vert0.angle, vert1.v2, vert1.angle, end_radius)

func compute_intersection(intersection: RoadIntersection):
	# DrawingUtils.draw_empty_circle($ImmediateGeometry, intersection.position, 0.5, Color.lightcyan)

	var intersection_verts = {}
	var start_points = []
	for connection in intersection.connections:
		if connection.road_network_info.segment_width != 0:
			var vert = {}
			var intersection_bound_for
			if connection is RoadSegmentBezier:
				intersection_bound_for = connection.middle_position if intersection == connection.start_position else connection.end_position if intersection == connection.middle_position else connection.middle_position if intersection == connection.end_position else connection.start_position
			else:
				intersection_bound_for = connection.start_position if intersection == connection.end_position else connection.end_position
			var direction
			if (connection is RoadSegmentBezier and intersection != connection.middle_position) or not connection is RoadSegmentBezier:
				direction = intersection.direction_to(intersection_bound_for)
			else:
				direction = get_average_direction_to(intersection, intersection_bound_for, connection)
			var start_point = intersection.position
			if intersection.connections.size() > 1:
				start_point += direction * (connection.road_network_info.length + ((connection.road_network_info.segment_width)/2) + (pow(intersection.connections.size(), connection.road_network_info.curvature)/2.0))
#				print(intersection.road_network_info.length + (connection.road_network_info.segment_width-1) + (pow(intersection.connections.size(), 0.3)/3.0))
			start_points.append(start_point)
#			DrawingUtils.draw_empty_circle($ImmediateGeometry, start_point, 0.25, Color.yellow)
			vert["start_position"] = start_point
			var left = Vector3(-direction.z, direction.y, direction.x)
			left = left.normalized()
			var v1 = start_point + left * connection.road_network_info.segment_width * 0.5
			var v2 = start_point + -left * connection.road_network_info.segment_width * 0.5
			vert["v1"] = v1
			vert["v2"] = v2
			vert["angle"] = atan2(direction.x, direction.z)
			DrawingUtils.draw_empty_circle(immediate_geometry_node, v1, 0.125, Color.red)
			DrawingUtils.draw_empty_circle(immediate_geometry_node, v2, 0.125, Color.green)
			intersection_verts[connection] = vert

	var connections = intersection.connections
	var mid_points = []
	for connection_idx in connections.size()-1:
		if connections[connection_idx].road_network_info.segment_width != 0:
			var point = compute_edge_intersection(intersection_verts[connections[connection_idx]], intersection_verts[connections[connection_idx+1]], intersection.road_network_info.end_radius)
#			DrawingUtils.draw_empty_circle($ImmediateGeometry, point, 0.125, Color.bisque)
			mid_points.append(point)
	if connections.size():
		var point = compute_edge_intersection(intersection_verts[connections[-1]], intersection_verts[connections[0]], intersection.road_network_info.end_radius)
#	DrawingUtils.draw_empty_circle($ImmediateGeometry, point, 0.125, Color.orange)
		mid_points.append(point)
		
	return [intersection_verts, mid_points]

func get_average_direction_to(intersection: RoadIntersection, position: RoadIntersection, connection: RoadSegmentBezier):
	var projected_time = connection.project_point(position.position, true)[1]
	var direction = Vector3.ZERO
	for t in range(0, projected_time, 0.01):
		direction += intersection.position.direction_to(connection.get_point(t))
		direction = direction.normalized()
	return direction


func draw_connection(_surface_tool: SurfaceTool, i1: Dictionary, i2: Dictionary, resolution: int = 20):
	var last_v1 = i1.v1
	var last_v2 = i1.v2
	for i in resolution+1:
		var t = i/float(resolution)
		var v1 = lerp(i1.v2, i2.v1, t)
		var v2 = lerp(i1.v1, i2.v2, t)
		_surface_tool.draw_triangle(
			last_v1,
			v1,
			v2)
		_surface_tool.draw_triangle( 
			last_v2,
			v1,
			last_v1)
		last_v1 = v2
		last_v2 = v1


func draw_lanes(_surface_tool: SurfaceTool, connection: RoadSegmentLinear):
	$ImmediateGeometry.begin(Mesh.PRIMITIVE_LINES)
	for lane in connection.lanes:
		var direction = connection.start_position.direction_to(connection.end_position)
		var left = Vector3(-direction.z, direction.y, direction.x)
		DrawingUtils.draw_line($ImmediateGeometry, connection.start_position.position+left*(lane.lane_info.offset+lane.lane_info.width/2), connection.end_position.position+left*(lane.lane_info.offset+lane.lane_info.width/2))
		DrawingUtils.draw_line($ImmediateGeometry, connection.start_position.position+left*(lane.lane_info.offset+-lane.lane_info.width/2), connection.end_position.position+left*(lane.lane_info.offset+-lane.lane_info.width/2))
	$ImmediateGeometry.end()

func draw_bezier_connection(_surface_tool, i1: Dictionary, m_i: Dictionary, i2: Dictionary, resolution: int = 20):
#	print(m_i.v1, m_i.v2)
	var half_width = i1.v1.distance_to(i1.v2)/2.0
	var start = (i1.v1 + i1.v2) / 2.0
	var midpoint = (m_i.v1 + m_i.v2) / 2.0
	var end = (i2.v1 + i2.v2) / 2.0
	var center_points = []
	for i in resolution+1:
		var t = i/float(resolution)
		center_points.append(quadratic_bezier(start, midpoint, end, t))

	var last_v1 = i1.v1
	var last_v2 = i1.v2
	for i in range(1, center_points.size()-1):
		var current_point = center_points[i]
		var dir1 = center_points[i-1].direction_to(current_point)
		var dir2 = current_point.direction_to(center_points[i+1])
		var dir = (dir1 + dir2)/2.0
		dir = Vector3(dir.z, dir.y, -dir.x)		# orthogonal direction
		var v2 = current_point - dir * half_width
		var v1 = current_point + dir * half_width
		_surface_tool.draw_triangle(
			last_v1,
			v1,
			v2)
		_surface_tool.draw_triangle( 
			last_v2,
			v1,
			last_v1)
		last_v1 = v2
		last_v2 = v1

	_surface_tool.draw_triangle(
		last_v1,
		i2.v1,
		i2.v2)
	_surface_tool.draw_triangle( 
		last_v2,
		i2.v1,
		last_v1)

func draw_complete_intersection(_surface_tool, intersection: RoadIntersection, vertex_data, mid_point_data):
#	if self.name == "GlobalRoadSystemDrawer":
#		push_warning("%s %s %s %s" % [intersection.visible_connections, intersection.visible_connections.size(), intersection.connections, intersection.connections.size()])
	if intersection.connections.size() == 1:
		var v1 = vertex_data[vertex_data.keys()[0]].v1
		var v2 = vertex_data[vertex_data.keys()[0]].v2
		var offset_midpoint = mid_point_data[0]
		var real_midpoint = (v1 + v2) / 2.0
		var offset = offset_midpoint - real_midpoint
		_surface_tool.draw_curve_triangles(v1, v1 + offset, offset_midpoint, real_midpoint)
		_surface_tool.draw_curve_triangles(offset_midpoint, v2 + offset, v2, real_midpoint)
	elif intersection.connections.size() > 1:
		var vertex0 = vertex_data[vertex_data.keys()[0]]
		var midpoint0 = (vertex0.v1 + vertex0.v2) / 2.0
		var vertex1 = vertex_data[vertex_data.keys()[1]]
		var midpoint1 = (vertex1.v1 + vertex1.v2) / 2.0
		
		var road_center_intersection = compute_intersection_values(midpoint0, vertex0.angle, midpoint1, vertex1.angle, intersection.road_network_info.end_radius)
		var intersection_center = quadratic_bezier(midpoint0, road_center_intersection, midpoint1, 0.5)

		var number_of_connections = intersection.connections.size()
		for connection_idx in number_of_connections:
			if intersection.connections[connection_idx].road_network_info.segment_width != 0 and intersection.connections[connection_idx].visible and intersection.connections[(connection_idx+1) % number_of_connections].visible:
				_surface_tool.draw_curve_triangles(vertex_data[vertex_data.keys()[connection_idx]].v1,
					mid_point_data[connection_idx],
					vertex_data[vertex_data.keys()[(connection_idx+1) % number_of_connections]].v2,
					intersection_center)
				var p0 = vertex_data[vertex_data.keys()[connection_idx]].v2
				var p1 = vertex_data[vertex_data.keys()[connection_idx]].v1
				_surface_tool.draw_triangle(p0,
					p1,
					intersection_center
				)

	# DrawingUtils.draw_line($ImmediateGeometry, vertex_data[-1].v1, mid_point_data[-1], Color.red)
	# DrawingUtils.draw_line($ImmediateGeometry, vertex_data[0].v2, mid_oint_data[-1], Color.red)
		
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
	

func _on_RoadNetwork_graph_changed():
	_render_road(get_parent())

func update():
	_render_road(get_parent())

func _input(event):
	if event is InputEventKey:
		if event.scancode == KEY_L and rendering_mode == Mesh.PRIMITIVE_LINES and event.pressed:
			rendering_mode = Mesh.PRIMITIVE_TRIANGLES
			_render_road(get_parent())
		elif event.scancode == KEY_L and rendering_mode == Mesh.PRIMITIVE_TRIANGLES and event.pressed:
			rendering_mode = Mesh.PRIMITIVE_LINES
			_render_road(get_parent())
