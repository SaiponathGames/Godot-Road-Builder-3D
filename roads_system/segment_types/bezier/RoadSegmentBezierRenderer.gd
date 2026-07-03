extends RoadSegmentBaseRenderer
class_name RoadSegmentBezierRenderer

func render(mesh_drawer: MeshDrawer, segment, debug_immediate_geo: ImmediateGeometry, resolution: int = 16):
	print("Rendering segment", segment)
	
	var positions = []
	positions.append(segment.start_position.position)
	for i in resolution+1:
		var t = i/float(resolution)
		print(t)
#		if t > 0.9:
#			breakpoint
		var v1 = segment.get_lerp_func().call_func(segment.start_position.position, segment.middle_position.position, segment.end_position.position, t)
		positions.append(v1)
#	positions.append(segment.end_position.position)
#
	
	var sidewalk_width = segment.road_network_info.sidewalk_width
	var sidewalk_height = segment.road_network_info.sidewalk_height
	
#	print(s_v1, s_v2, e_v1, e_v2, m_v1, m_v2)
	
	var s_v1 = segment.start_position.get_left_vertex()
	var s_v2 = segment.start_position.get_right_vertex()
	
	var sp = segment.start_position.position
	var ep = segment.end_position.position
	var mp0 = segment.middle_position.position
	
	var e_v1 = segment.end_position.get_left_vertex()
	var e_v2 = segment.end_position.get_right_vertex()
	
	var dir = segment.direction_from_intersection(segment.start_position)
	DrawingUtils.draw_line(debug_immediate_geo, segment.start_position.position, segment.start_position.position + -dir * 2, Color.blueviolet)
	DrawingUtils.draw_line(debug_immediate_geo, segment.start_position.position, segment.start_position.position + left_dir(-dir) * 2, Color.blueviolet)
	
	var last_v1 = s_v1
	var last_v2 = s_v2
	
	var last_v1_sw_hei = last_v2 + Vector3.UP * sidewalk_height
	var last_v1_sw_widBas = last_v2 + left_dir(dir) * sidewalk_width
	var last_v1_sw_widBaseHei = last_v2 + left_dir(dir) * sidewalk_width + Vector3.UP * sidewalk_height
	
	var last_v2_sw_hei = last_v1 + Vector3.UP * sidewalk_height
	var last_v2_sw_widBas = last_v1 + left_dir(dir) * sidewalk_width
	var last_v2_sw_widBaseHei = last_v1 + left_dir(dir) * sidewalk_width + Vector3.UP * sidewalk_height
	
	
#	mesh_drawer.draw_triangle(
#		last_v2, last_v1, s_v2 
#	)
#
#	mesh_drawer.draw_triangle(
#		s_v2, last_v1, s_v1
#	)
#
#	mesh_drawer.draw_triangle(
#		s_v2, s_v1, last_v2 
#	)
#
#	mesh_drawer.draw_triangle(
#		last_v2, s_v1, last_v1
#	)
	DrawingUtils.draw_line(debug_immediate_geo, sp, last_v1, Color.yellow)
	DrawingUtils.draw_empty_circle(debug_immediate_geo, last_v1, 0.125, Color.blue)
	DrawingUtils.draw_empty_circle(debug_immediate_geo, last_v2, 0.125, Color.black)
	
	var ldir = dir.cross(Vector3.UP)
	
	for i in range(1, resolution+2):
		
		var t = (i-1) / float(resolution)
		prints("New t", t)
		var tangent = 2 * (1 - t) * (mp0 - sp) + 2 * t * (ep - mp0)
		dir = tangent.normalized()
		var raw_extrude = dir.cross(Vector3.UP)
		if raw_extrude.length_squared() > 0.001:
			var new_ldir = raw_extrude.normalized()
			if new_ldir.dot(ldir) < 0.0:
				new_ldir = -new_ldir
			ldir = new_ldir
		
		var v = segment.get_point(t)
		var v1 = get_left_vertex(v, ldir, segment)
		var v2 = get_right_vertex(v, ldir, segment)
		DrawingUtils.draw_line(debug_immediate_geo, v, v + dir * 2, Color.orange)	
		DrawingUtils.draw_empty_circle(debug_immediate_geo, v1, 0.125, Color.yellow)
		DrawingUtils.draw_empty_circle(debug_immediate_geo, v2, 0.125, Color.red)
		mesh_drawer.draw_triangle(
			v2,
			v1,
			last_v1)
		mesh_drawer.draw_triangle(
			last_v1,
			v1,
			last_v2)
		
		var v1_sw_hei = Vector3(v1.x, v1.y + sidewalk_height, v1.z)
		var v1_sw_widBas = v1 + ldir * sidewalk_width
		var v1_sw_widHeiBas = v1 + ldir * sidewalk_width + Vector3.UP * sidewalk_height
		
		var v2_sw_hei = Vector3(v2.x, v2.y + sidewalk_height, v2.z)
		var v2_sw_widBas = v2 + -ldir * sidewalk_width
		var v2_sw_widHeiBas = v2 + -ldir * sidewalk_width + Vector3.UP * sidewalk_height
		
		
		if i > 1:
			# v1
			mesh_drawer.draw_triangle(
				v1, v1_sw_hei, last_v2, Color.aqua
			)

			mesh_drawer.draw_triangle(
				last_v2, v1_sw_hei, last_v1_sw_widBaseHei, Color.red
			)

			mesh_drawer.draw_triangle(
				last_v1_sw_widBas, v1_sw_widHeiBas, v1_sw_widBas, Color.orange
			)

			mesh_drawer.draw_triangle(
				last_v1_sw_hei, v1_sw_widHeiBas, last_v1_sw_widBas, Color.purple
			)

			# v2
			mesh_drawer.draw_triangle(
				last_v1, v2_sw_hei, v2, Color.aqua
			)

			mesh_drawer.draw_triangle(
				last_v2_sw_widBaseHei, v2_sw_hei, last_v1, Color.red
			)

			mesh_drawer.draw_triangle(
				v2_sw_widBas, v2_sw_widHeiBas, last_v2_sw_widBas, Color.orange
			)

			mesh_drawer.draw_triangle(
				last_v2_sw_widBas, v2_sw_widHeiBas, last_v2_sw_hei, Color.purple
			)
	
			mesh_drawer.draw_triangle(
				v1_sw_hei, v1_sw_widHeiBas, last_v1_sw_widBaseHei, Color.sandybrown
			)
			
			mesh_drawer.draw_triangle(
				last_v1_sw_widBaseHei, v1_sw_widHeiBas, last_v1_sw_hei, Color.sandybrown
			)
			
			mesh_drawer.draw_triangle(
				last_v2_sw_widBaseHei, v2_sw_widHeiBas, v2_sw_hei, Color.sandybrown
			)
			
			mesh_drawer.draw_triangle(
				last_v2_sw_hei, v2_sw_widHeiBas, last_v2_sw_widBaseHei, Color.sandybrown
			)

		last_v1 = v2
		last_v2 = v1
		
		last_v1_sw_hei = v1_sw_widHeiBas
		last_v1_sw_widBaseHei = v1_sw_hei
		last_v1_sw_widBas = v1_sw_widBas
		
		last_v2_sw_hei = v2_sw_widHeiBas
		last_v2_sw_widBaseHei = v2_sw_hei
		last_v2_sw_widBas= v2_sw_widBas
	
	mesh_drawer.draw_triangle(
		last_v2, last_v1, e_v2 
	)

	mesh_drawer.draw_triangle(
		e_v2, last_v1, e_v1
	)
#
#	mesh_drawer.draw_triangle(
#		e_v2, e_v1, last_v2 
#	)
#
#	mesh_drawer.draw_triangle(
#		last_v2, e_v1, last_v1
#	)
		
	DrawingUtils.draw_empty_circle(debug_immediate_geo, s_v1, 0.125, Color.black)
	DrawingUtils.draw_empty_circle(debug_immediate_geo, s_v2, 0.125, Color.black)
	
#	DrawingUtils.draw_empty_circle(debug_immediate_geo, e_v1, 0.125, Color.red)
#	DrawingUtils.draw_empty_circle(debug_immediate_geo, e_v2, 0.125, Color.red)
	
#	DrawingUtils.draw_empty_circle(debug_immediate_geo, m_v1, 0.125, Color.blue)
#	DrawingUtils.draw_empty_circle(debug_immediate_geo, m_v2, 0.125, Color.blue)

func avg_direction(position: Vector3, next_pos: Vector3, previous_pos: Vector3) -> Vector3:
	if !is_vec_nan(previous_pos) and !is_vec_nan(next_pos):
		var avg_pos = previous_pos.direction_to(next_pos)
		return avg_pos.normalized()
	elif is_vec_nan(next_pos):
		return previous_pos.direction_to(position).normalized()
	elif is_vec_nan(previous_pos):
		return position.direction_to(next_pos).normalized()
	else:
		return Vector3(NAN, NAN, NAN)

func is_vec_nan(vec) -> bool:
	if typeof(vec) == TYPE_VECTOR3:
		return is_nan(vec.x) and is_nan(vec.y) and is_nan(vec.z)
	if typeof(vec) == TYPE_VECTOR2:
		return is_nan(vec.x) and is_nan(vec.y)
	if typeof(vec) == TYPE_REAL:
		return is_nan(vec)
	return false

func left_dir(dir, up: Vector3 = Vector3.UP) -> Vector3:
	var left = dir.cross(up)
	return left

func get_left_vertex(position: Vector3, ldir: Vector3, segment: RoadSegmentBase):
	return position + ldir * segment.road_network_info.segment_width/2

func get_right_vertex(position: Vector3, ldir: Vector3, segment: RoadSegmentBase):
	return position + -ldir * segment.road_network_info.segment_width/2

