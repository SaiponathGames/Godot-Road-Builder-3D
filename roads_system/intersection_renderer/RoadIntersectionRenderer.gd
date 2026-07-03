extends Reference
class_name RoadIntersectionRenderer

var sidewalk_height = 0.062
var sidewalk_width = 0.5

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
		var dir0 = connection.segment.direction_from_intersection(connection).normalized()
		var angle0 = atan2(dir0.x, dir0.z)
		var dir1 = next_connection.segment.direction_from_intersection(next_connection).normalized()
		var angle1 = atan2(dir1.x, dir1.z)
		
		DrawingUtils.draw_line(_immediate_geo, connection.position, connection.position + dir0 * 2, Color.red)
		DrawingUtils.draw_line(_immediate_geo, connection.position, connection.position + dir0.cross(Vector3.UP) * 2)
		
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
			
			var v1_h = v1 + Vector3.UP * sidewalk_height
			var v2_h = v2 + Vector3.UP * sidewalk_height
			var omp_h = offset_midpoint + Vector3.UP * sidewalk_height
			var rmp_h = real_midpoint + Vector3.UP * sidewalk_height
			# omp = offset midpoint
			# rmp = real midpoint
			
			var v1_mid = v1 + Vector3.UP * (sidewalk_height) / 2.0
			var v2_mid = v2 + Vector3.UP * (sidewalk_height) / 2.0
			var omp_mid = offset_midpoint + Vector3.UP * (sidewalk_height) / 2.0
			var rmp_mid = real_midpoint + Vector3.UP * sidewalk_height / 2.0
			
			var ldir0 = Vector3(-dir0.z, 0, dir0.x).normalized()
			
			# height & width
			var v1_hfw = v1_h + ldir0 * sidewalk_width / 2.0
			var v2_hfw = v2_h + -ldir0 * sidewalk_width / 2.0
			var omp_hfw = omp_h + -dir0 * sidewalk_width / 2.0
			
			# half height
			var v1_hfww = v1_h + ldir0 * sidewalk_width - Vector3.UP * sidewalk_height / 2.0
			var v2_hfww = v2_h + -ldir0 * sidewalk_width - Vector3.UP * sidewalk_height / 2.0
			var omp_hfww = omp_h + -dir0 * sidewalk_width - Vector3.UP * sidewalk_height / 2.0
			var rmp_hfww = rmp_h - Vector3.UP * sidewalk_height / 2.0
			
			var h_offset = omp_hfw - rmp_h 
			var h2_offset = (omp_mid - rmp_mid) * 1.05 # innter radius adjustment factor
			var h3_offset = (omp_hfww - rmp_hfww) * 0.97 # Outer radius adjustment factor
			
			var sw_hdir0 = ldir0.cross(dir0).normalized()
			
			_mesh_drawer.draw_curved_quad_w(
				v1_hfw, v1_hfw+h_offset, omp_hfw, ldir0, sidewalk_width / 2.0, Vector3.UP
			)

			_mesh_drawer.draw_curved_quad_w(
				v2_hfw, v2_hfw+h_offset, omp_hfw, ldir0, sidewalk_width / 2.0, Vector3.UP
			)
			
			_mesh_drawer.draw_curved_quad_w(
				v1_hfww, v1_hfww+h3_offset, omp_hfww, -sw_hdir0, sidewalk_height / 2.0, Vector3.RIGHT
			)

			_mesh_drawer.draw_curved_quad_w(
				omp_hfww, v2_hfww+h3_offset, v2_hfww, -sw_hdir0, sidewalk_height / 2.0, Vector3.RIGHT
			)

			_mesh_drawer.draw_curved_quad_w(
				v1_mid, v1_mid+h2_offset, omp_mid, sw_hdir0, sidewalk_height / 2.0, Vector3.LEFT
			)
			
			_mesh_drawer.draw_curved_quad_w(
				omp_mid, v2_mid+h2_offset, v2_mid, sw_hdir0, sidewalk_height / 2.0, Vector3.LEFT
			)
			
			
			
#			DrawingUtils.draw_empty_circle(_immediate_geo, v1+offset, .25, Color.aqua)
#			DrawingUtils.draw_empty_circle(_immediate_geo, v2+offset, .25, Color.brown)
#			DrawingUtils.draw_empty_circle(_immediate_geo, offset_midpoint, .25, Color.black)
#			DrawingUtils.draw_line(_immediate_geo, offset_midpoint, v1+offset)
#			DrawingUtils.draw_line(_immediate_geo, v1+offset, v1)

			DrawingUtils.draw_empty_circle(_immediate_geo, v1_hfw, 0.0625, Color.aqua)
			DrawingUtils.draw_empty_circle(_immediate_geo, v1_hfw+offset, 0.0625, Color.black)
			DrawingUtils.draw_empty_circle(_immediate_geo, v1_hfw+h_offset, 0.0625, Color.blue)
			DrawingUtils.draw_empty_circle(_immediate_geo, omp_hfw, 0.0625, Color.yellow)
			DrawingUtils.draw_empty_circle(_immediate_geo, v1_hfww, 0.0625, Color.yellowgreen)
			
		
			
			
#			DrawingUtils.draw_empty_circle(_immediate_geo, connection.get_left_vertex(), 0.25, Color.aqua)
#			DrawingUtils.draw_empty_circle(_immediate_geo, next_connection.get_right_vertex(), 0.25, Color.gold)
			_mesh_drawer.draw_curve_triangles(
				v1,
				v1+offset * 1.05,
				offset_midpoint,
				real_midpoint,
				Color.red,
				resolution
			)
			
			_mesh_drawer.draw_curve_triangles(
				offset_midpoint,
				v2+offset * 1.05,
				v2,
				real_midpoint,
				Color.blue,
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
		var v1 = connection.get_left_vertex()
		var v2 = next_connection.get_right_vertex()
		var mid = midpoint
		
		var v1_h = connection.get_left_vertex() + Vector3.UP * sidewalk_height
		var v2_h = next_connection.get_right_vertex() + Vector3.UP * sidewalk_height
		var mid_h = midpoint + Vector3.UP * sidewalk_height
		
		var v1_wid = v1 + left_dir(dir0) * sidewalk_width
		var v2_wid = v2 + -left_dir(dir1) * sidewalk_width
		
		var sw_widMid = compute_edge_intersection(
			v1_wid, 
			v2_wid, 
			angle0,
			angle1,
			end_radius
		)
		
		var v1_widHei = v1_h + left_dir(dir0) * sidewalk_width
		var v2_widHei = v2_h + -left_dir(dir1) * sidewalk_width
		var sw_midpoint = compute_edge_intersection(
			v1_widHei, 
			v2_widHei, 
			angle0,
			angle1,
			end_radius
		)
		
#		if not con_idx == new_idx:
		_mesh_drawer.draw_triangle(
			connection.get_left_vertex(), 
			_road_intersection.position,
			connection.get_right_vertex()
		)
		
		_mesh_drawer.draw_curved_quad(
				v1_h, mid_h, v2_h, v1_widHei, sw_midpoint, v2_widHei, Color.sandybrown
		)
		_mesh_drawer.draw_curved_quad(
			v1, mid, v2, v1_h, mid_h, v2_h, Color.brown
		)
		_mesh_drawer.draw_curved_quad(
			v2_wid, sw_widMid, v1_wid, v2_widHei, sw_midpoint, v1_widHei, Color.brown
		)

#		_mesh_drawer.draw_curved_quad_w(
#			v2_hfw, v2_hfw+h_offset, omp_hfw, ldir0, sidewalk_width / 2.0, Vector3.UP
#		)
		
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
		


func left_dir(v: Vector3, up: Vector3 = Vector3.UP) -> Vector3:
	return v.cross(up)

# Implemented by Jaynabonne.
func compute_edge_intersection(p0, p1, angle0, angle1, end_radius):
	var midpoint = (p0+p1)/2.0
	var adiff = wrapf(angle1 - angle0, -PI, PI)
	var arc = abs(adiff)
	var v = Vector2(cos(angle0), sin(angle0))
	v += Vector2(cos(angle1), sin(angle1))
	var midangle = atan2(v.y, v.x)
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
