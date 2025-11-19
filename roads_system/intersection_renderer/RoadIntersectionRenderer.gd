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
		connection = connection as RoadIntersectionNode
		var new_idx = (con_idx+1) % connections.size()
		prints(con_idx, new_idx)
		var next_connection = connections.keys()[new_idx]
		var dir0 = connection.direction
		var angle0 = atan2(dir0.x, dir0.z)
		var dir1 = next_connection.direction
		var angle1 = atan2(dir1.x, dir1.z)
		
		if !is_instance_valid(connection.segment) or !is_instance_valid(next_connection.segment):
			continue
		
		
		print(connection == next_connection)
		
		# Use 1.25 for the best looks
		var end_radius = _road_intersection.road_network_info.segment_width
		# Implemented by Jaynabonne (Thanks a ton!)
		var midpoint = compute_edge_intersection(
			connection.get_left_vertex(), 
			next_connection.get_right_vertex(), 
			angle0,
			angle1,
			end_radius
		)

		
		midpoints[connection] = midpoint
		DrawingUtils.draw_empty_circle(_immediate_geo, midpoint, 0.125, Color.blue)
		
		con_idx += 1
		
		if connections.size() == 1:
			print("Generating cap")
			# Cap generation
			var v1 = connection.get_left_vertex()
			var v2 = connection.get_right_vertex()
			var offset_midpoint = midpoint + dir0 * 0.5
			var real_midpoint = (v1 + v2) / 2.0
			var offset = offset_midpoint - real_midpoint
			DrawingUtils.draw_empty_circle(_immediate_geo, connection.get_left_vertex(), 0.25, Color.aqua)
			DrawingUtils.draw_empty_circle(_immediate_geo, next_connection.get_right_vertex(), 0.25, Color.gold)
			_mesh_drawer.draw_curve_triangles(
				v1,
				v1+offset,
				offset_midpoint,
				real_midpoint,
				Color.white,
				resolution
			)
			_mesh_drawer.draw_curve_triangles(
				offset_midpoint,
				v2+offset,
				v2,
				real_midpoint,
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
