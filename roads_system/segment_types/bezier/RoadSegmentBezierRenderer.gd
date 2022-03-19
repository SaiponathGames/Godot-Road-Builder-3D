extends RoadSegmentBaseRenderer
class_name RoadSegmentBezierRenderer

func render(mesh_drawer: MeshDrawer, segment, debug_immediate_geo: ImmediateGeometry, resolution: int = 16):
	print("Rendering segment", segment)
	
	var positions = []
	for i in resolution+1:
		var t = i/float(resolution)
#		if t > 0.9:
#			breakpoint
		var v1 = segment.get_lerp_func().call_func(segment.start_position.position, segment.middle_position.position, segment.end_position.position, t)
		positions.append(v1)
	
#	print(s_v1, s_v2, e_v1, e_v2, m_v1, m_v2)
	
	var last_v2 = get_left_vertex_from_index(0, positions, segment)
	var last_v1 = get_right_vertex_from_index(0, positions, segment)
	
	DrawingUtils.draw_empty_circle(debug_immediate_geo, last_v1, 0.125, Color.blue)
	DrawingUtils.draw_empty_circle(debug_immediate_geo, last_v2, 0.125, Color.black)
	
	
	for i in range(1, resolution+1):
		var v1 = get_left_vertex_from_index(i, positions, segment)
		var v2 = get_right_vertex_from_index(i, positions, segment)
		
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
		last_v1 = v2
		last_v2 = v1
		
#	DrawingUtils.draw_empty_circle(debug_immediate_geo, s_v1, 0.125, Color.black)
#	DrawingUtils.draw_empty_circle(debug_immediate_geo, s_v2, 0.125, Color.black)
	
#	DrawingUtils.draw_empty_circle(debug_immediate_geo, e_v1, 0.125, Color.red)
#	DrawingUtils.draw_empty_circle(debug_immediate_geo, e_v2, 0.125, Color.red)
	
#	DrawingUtils.draw_empty_circle(debug_immediate_geo, m_v1, 0.125, Color.blue)
#	DrawingUtils.draw_empty_circle(debug_immediate_geo, m_v2, 0.125, Color.blue)

func avg_direction(position: Vector3, next_pos: Vector3, previous_pos: Vector3) -> Vector3:
	if !is_vec_nan(previous_pos) and !is_vec_nan(next_pos):
		var avg_pos = position.direction_to(next_pos) + previous_pos.direction_to(next_pos)
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

func get_left_vertex(position: Vector3, next_pos: Vector3, previous_pos: Vector3, segment: RoadSegmentBase):
	var direction = avg_direction(position, next_pos, previous_pos)
	var left = Vector3(-direction.z, direction.y, direction.x)
	return position + left * segment.road_network_info.segment_width/2

func get_right_vertex(position: Vector3, next_pos: Vector3, previous_pos: Vector3, segment: RoadSegmentBase):
	var direction = avg_direction(position, next_pos, previous_pos)
	var left = Vector3(-direction.z, direction.y, direction.x)
	return position + -left * segment.road_network_info.segment_width/2

func get_left_vertex_from_index(index, array, segment):
	var v1
	if index < 1: # start case
		v1 = get_left_vertex(array[0], array[1], Vector3(NAN, NAN, NAN), segment)
	elif index > 0 and index+1 < array.size(): # middle case
		v1 = get_left_vertex(array[index], array[index+1], array[index-1], segment)
	elif index-1 < array.size(): # end case
		v1 = get_left_vertex(array[index], Vector3(NAN, NAN, NAN), array[index-1], segment)
	return v1

func get_right_vertex_from_index(index, array, segment):
	var v1
	if index < 1: # start case
		v1 = get_right_vertex(array[0], array[1], Vector3(NAN, NAN, NAN), segment)
	elif index > 0 and index+1 < array.size(): # middle case
		v1 = get_right_vertex(array[index], array[index+1], array[index-1], segment)
	elif index-1 < array.size(): # end case
		v1 = get_right_vertex(array[index], Vector3(NAN, NAN, NAN), array[index-1], segment)
	return v1
