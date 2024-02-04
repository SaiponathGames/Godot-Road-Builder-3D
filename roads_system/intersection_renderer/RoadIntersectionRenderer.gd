extends Reference
class_name RoadIntersectionRenderer

func render(_mesh_drawer: MeshDrawer, _road_intersection, _immediate_geo: ImmediateGeometry):
	# implement the rendering system
	var resolution = 10
	var midpoints = {}
	var con_idx = 0
	var sorter = CustomSorter.new(self, "sort_by_angle", [_road_intersection])
	var connections = sorter.sort_dict(_road_intersection.connections)
	for connection in connections:
		var new_idx = (con_idx+1) % connections.size()
		prints(con_idx, new_idx)
		var next_connection = connections.keys()[new_idx]
		var angle0 = atan2(connection.direction.x, connection.direction.z)
		var dir1 = next_connection.direction
		var angle1 = atan2(dir1.x, dir1.z)
		
		# Implemented by Jaynabonne (Thanks a ton!)
		var midpoint = compute_edge_intersection(
			connection.get_left_vertex(), 
			next_connection.get_right_vertex(), 
			angle0,
			angle1,
			_road_intersection.road_network_info.intersection_end_radius
		)

		
		midpoints[connection] = midpoint
		DrawingUtils.draw_empty_circle(_immediate_geo, midpoint, 0.125, Color.blue)
		
		con_idx += 1
		
		if connections.size() == 1:
			# Cap generation
			var hermite_offset = (midpoint - connection.position)
			_mesh_drawer.draw_curve_triangles(
				connection.get_left_vertex(),
				midpoint+hermite_offset,
				connection.get_right_vertex(),
				connection.position,
				Color.white,
				resolution
			)
			continue
		_mesh_drawer.draw_curve_triangles(
			connection.get_left_vertex(),
			midpoint,
			next_connection.get_right_vertex(),
			_road_intersection.position,
			Color.white,
			resolution
		)
#		if not con_idx == new_idx:
		_mesh_drawer.draw_triangle(
			connection.get_left_vertex(), 
			_road_intersection.position,
			connection.get_right_vertex()
		)
		
		# debug
		_immediate_geo.begin(Mesh.PRIMITIVE_LINES)
		DrawingUtils.draw_curve(
			_immediate_geo, 
			connection.get_left_vertex(),
			midpoint,
			next_connection.get_right_vertex()
		)
		_immediate_geo.end()
#		DrawingUtils.draw_line(
#			_immediate_geo,
#			connection.get_left_vertex(),
#			midpoint
#		)
#
#		DrawingUtils.draw_line(
#			_immediate_geo,
#			midpoint,
#			next_connection.get_right_vertex()
#		)
		
	
		

# Implemented by Jaynabonne.
func compute_edge_intersection(p0, p1, angle0, angle1, end_radius):
	var midpoint = (p0+p1)/2.0
	var arc = abs(angle0 - angle1)
	var midangle = (angle0 + angle1)/2.0
	var offset = Vector3()
	if not is_zero_approx(arc):
		offset = Vector3(sin(midangle), 0, cos(midangle))*midpoint.distance_to(p0)/tan(arc/2)
	else:
		offset = Vector3(sin(midangle), 0, cos(midangle))*midpoint.distance_to(p0) * end_radius
	return midpoint - offset

# found this on unity Q/A modified it to suite the needs of godot
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
