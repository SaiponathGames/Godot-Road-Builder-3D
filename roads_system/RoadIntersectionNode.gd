extends Object
class_name RoadIntersectionNode

var position: Vector3 = Vector3.ZERO
var offset: Vector2 = Vector2(NAN, NAN)
var direction: Vector3
var _og_position: Vector3

var left_offset: float
var right_offset: float

var intersection # RoadIntersection
var segment # RoadSegmentBase
var road_network # RoadNetwork

var id
func _init(_intersection, _segment):
	intersection = _intersection
	segment = _segment
	position = _intersection.position
	road_network = _intersection.road_network
	id = intersection.id + segment.id
	_og_position = _intersection.position

func set_owner(road_net):
	road_network = road_net
	if road_net:
		id = intersection.id + segment.id
#	set_offset(Vector2(NAN, NAN), 0)

func distance_to(to_intersection: RoadIntersectionNode):
	return self.position.distance_to(to_intersection.position)

func direction_to(_intersection: RoadIntersectionNode):
	if !is_instance_valid(_intersection):
		return Vector3.ZERO
	return self.position.direction_to(_intersection.position)

func get_left_vertex():
	if !is_instance_valid(segment):
		return
#	var direction = segment.direction_from_intersection(self)
	var left = Vector3(-direction.z, direction.y, direction.x).normalized()
	return position + direction * left_offset + left * segment.road_network_info.segment_width/2

func get_right_vertex():
	if !is_instance_valid(segment):
		return
#	var direction = segment.direction_from_intersection(self)
	var left = Vector3(-direction.z, direction.y, direction.x).normalized()
	return position + direction * right_offset + -left * segment.road_network_info.segment_width/2

func set_offset(value: Vector2, con_idx: int):
	direction = segment.direction_from_intersection(self).normalized()
	if is_vec_nan(value):
		var res = calculate_offset(con_idx)
		left_offset = res[0]
		right_offset = res[1]
		prints(left_offset, right_offset)
		offset.y = min(left_offset, right_offset)
		offset.x = 0
		update_position()
	else:
		offset = value
		update_position()

func update_position():
#	position = _og_position + direction * offset.y
	position = _og_position + Vector3(-direction.z, direction.y, direction.x).normalized() * offset.x

func delete_node():
	if is_instance_valid(intersection):
		intersection.delete_node(self)
	call_deferred('free')

func _notification(what):
	match what:
		NOTIFICATION_PREDELETE:
			pass
#			if is_instance_valid(segment):
#				prints("About to be deleted RoadIntersectionNode", "IntersectionNode ID:", id, "Segment ID:", segment.id, 'RoadNetwork:', road_network)
#			elif is_instance_valid(intersection):
#				prints("About to be deleted RoadIntersectionNode", "IntersectionNode ID:", id, "Intersection ID:", intersection.id, 'RoadNetwork:', road_network)
#			elif is_instance_valid(segment) and is_instance_valid(intersection):
#				prints("About to be deleted RoadIntersectionNode", "IntersectionNode ID:", id, "Intersection ID:", intersection.id, "Segment ID:", segment.id, 'RoadNetwork:', road_network)
#			else:
#				prints("About to be deleted RoadIntersectionNode", "IntersectionNode ID:", id, 'RoadNetwork:', road_network)

#func _sort_by_angle(a, b):
#	return a.angle < b.angle
#
#func calculate_offset(con_idx: int):
#	var c = intersection.road_network_info.intersection_curvature
#	var l = intersection.road_network_info.intersection_length
#	var n = intersection.get_connected_nodes().size()
#	var w = segment.road_network_info.segment_width
#	var sw = segment.road_network_info.sidewalk_width

#	return [(c + l) * 2, (c + l) * 2]
#	if n > 2:
#		var conns = intersection._ordered_connections.keys()
#		var angled = []
#		for con in conns:
#			var d = con.segment.direction_from_intersection(con).normalized()
#			angled.append({ "con": con, "angle": atan2(-d.z, d.x) })
#		angled.sort_custom(self, "_sort_by_angle")
#
#		var sorted_n = angled.size()
#		var my_con = conns[con_idx]
#		var my_pos = -1
#		for i in sorted_n:
#			if angled[i].con == my_con:
#				my_pos = i
#				break
#
#		var prev_idx = wrapi(my_pos - 1, 0, sorted_n)
#		var next_idx = wrapi(my_pos + 1, 0, sorted_n)
#		var curr_angle = angled[my_pos].angle
#		var prev_angle = angled[prev_idx].angle
#		var next_angle = angled[next_idx].angle
#		prints("Prev Idx", prev_idx, "Cur Idx", my_pos, "Next Idx", next_idx)
#		prints("Prev Angle", rad2deg(prev_angle), "Cur Angle", rad2deg(curr_angle), "Next Angle", rad2deg(next_angle))
#
#
#		var left_gap  = abs(wrapf(curr_angle - prev_angle, -PI, PI))
#		var right_gap = abs(wrapf(next_angle - curr_angle, -PI, PI))
#
#		prints("Gaps(deg) [left, right]", rad2deg(left_gap), rad2deg(right_gap))
#
#		var outer_half_width = w * 0.5 + sw + c
#
#		var min_gap = deg2rad(15.0)
#		var result = [outer_half_width, outer_half_width]
#
#		# bevel fallback, no long tangent run
#		if left_gap > min_gap:
#			var trim_left = outer_half_width / tan(left_gap * 0.5)
#			result[0] = max(trim_left, outer_half_width)
#			prints("LeftGap", left_gap, "MinGap", min_gap, "TrimLeft", trim_left)
#		if right_gap > min_gap:
#			var trim_right = outer_half_width / tan(right_gap * 0.5)
#			result[1] = max(trim_right, outer_half_width)
#			prints("RightGap", right_gap, "MinGap", min_gap, "TrimRight", trim_right)
#
#
##		prints("Trim", trim, "ArcRadius", outer_half_width)
#
#		return result
#	else:
#		var result = (c + l) * 2 # if n < 5 else 0 + (n * w) * c * 0.95) + sw * 1.15
#		return [result, result]

func get_connection_angle(con) -> float:
	var far_position = con.segment.start_position.position if con.segment.end_position.intersection == intersection else con.segment.end_position.intersection.position
	var offset = far_position - intersection.position
	return atan2(offset.x, offset.z)

func calculate_offset(con_idx: int):
	var c = intersection.road_network_info.intersection_curvature
	var l = intersection.road_network_info.intersection_length
	var n = intersection.get_connected_nodes().size()
	var w = segment.road_network_info.segment_width
	var sw = segment.road_network_info.sidewalk_width

	if n > 2:
		var conns = intersection._ordered_connections.keys()
		var sorted_n = conns.size()
		print(intersection._ordered_connections.values())

		var prev_idx = wrapi(con_idx - 1, 0, sorted_n)
		var next_idx = wrapi(con_idx + 1, 0, sorted_n)
		var prev_con = conns[prev_idx]
		var next_con = conns[next_idx]

		var curr_angle = get_connection_angle(self)
		var prev_angle = get_connection_angle(prev_con)
		var next_angle = get_connection_angle(next_con)

		var left_gap  = abs(wrapf(curr_angle - prev_angle, -PI, PI))
		var right_gap = abs(wrapf(next_angle - curr_angle, -PI, PI))

		var outer_half_width = w * 0.5 + sw + c
		var min_gap = deg2rad(15.0)
		var result = [outer_half_width, outer_half_width]

		if left_gap > min_gap:
			result[1] = max(outer_half_width / tan(left_gap * 0.5), outer_half_width)
		if right_gap > min_gap:
			result[0] = max(outer_half_width / tan(right_gap * 0.5), outer_half_width)

		return result
	else:
		var result = (c + l) * 2
		return [result, result]

func is_vec_nan(vec) -> bool:
	if typeof(vec) == TYPE_VECTOR3:
		return is_nan(vec.x) and is_nan(vec.y) and is_nan(vec.z)
	if typeof(vec) == TYPE_VECTOR2:
		return is_nan(vec.x) and is_nan(vec.y)
	if typeof(vec) == TYPE_REAL:
		return is_nan(vec)
	return false
