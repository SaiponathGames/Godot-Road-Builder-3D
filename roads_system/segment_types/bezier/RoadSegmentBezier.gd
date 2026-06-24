extends RoadSegmentBase
class_name RoadSegmentBezier


var middle_position: RoadIntersectionNode

var lut = []

var current_resolution setget set_current_resolution

func _init(_start_position: RoadIntersection, _middle_position: RoadIntersection, _end_position: RoadIntersection, _road_net_info, _direction).(_start_position, _end_position, _road_net_info, _direction):
	self.middle_position = _middle_position.create_node(self)
	calculate_lut()
	modder_id = 0
	seg_type = 2
	custom_id = (5.625)*rad2deg(middle_position.intersection.angle_to(start_position.intersection))+rad2deg(middle_position.intersection.angle_to(end_position.intersection))
	positions.append(middle_position)
	renderer = RoadSegmentBezierRenderer
	
func set_current_resolution(value):
	current_resolution = value
	calculate_lut(value, false)

func _quadratic_bezier(p0: Vector3, p1: Vector3, p2: Vector3, t: float):
	var q0 = p0.linear_interpolate(p1, t)
	var q1 = p1.linear_interpolate(p2, t)
	return q0.linear_interpolate(q1, t)

func get_length(resolution = 16):
	if not (is_instance_valid(start_position) and is_instance_valid(middle_position) and is_instance_valid(end_position)):
		return
	var _lut = generate_lut(resolution)
	var sum = 0
	var previous_point = start_position.position
	for point_t in _lut:
		var point = point_t[0]
		sum += previous_point.distance_to(point)
		previous_point = point
	return sum

func get_point(t) -> Vector3:
	if not (is_instance_valid(start_position) and is_instance_valid(middle_position) and is_instance_valid(end_position)):
		return Vector3.ONE * NAN
	return _quadratic_bezier(start_position.position, middle_position.position, end_position.position, t)

func get_aabb():
	var minima = Vector3.INF
	var maxima = -Vector3.INF
	var r = road_network_info.segment_width * 0.5
	for point_t in lut:
		var point = point_t[0]
		minima = Vector3(min(minima.x, point.x), min(minima.y, point.y), min(minima.z, point.z))
		maxima = Vector3(max(maxima.x, point.x), max(maxima.y, point.y), max(maxima.z, point.z))
	minima -= Vector3.ONE * r
	maxima += Vector3.ONE * r
	var aabb = AABB(minima, Vector3.ONE)
	aabb.end = maxima
	return aabb

func _average_direction(road_intersection: RoadIntersection, position: RoadIntersection):
	var projected_time = project_point(road_intersection.position, true)[1]
	var direction = Vector3.ZERO
	for t in range(0, projected_time, 0.01):
		direction += position.position.direction_to(get_point(t))
	direction = direction.normalized()
	return direction

func project_point(position: Vector3, send_time = false):
	var i = 0
	var min_dist = INF
	var k = 0
	for point_t in lut:
		var dist = position.distance_to(point_t[0])
		if dist < min_dist:
			min_dist = dist
			i = k
		k += 1
	
	return _refine_binary(position, i, send_time)

func _refine_binary(point: Vector3, index: int, send_time = false,  max_iters = 25, span = 0.001):
	var _lut = self.lut.duplicate()
	var count = 0
	var dist = INF
	var point_on_curve = _lut[index][0]
	var return_t = -1
	while count < max_iters:
		var i1 = wrapi(index-1, 0, _lut.size())
		var i2 = wrapi(index+1, 0, _lut.size())
		
		var t1 = _lut[i1][1]
		var t2 = _lut[i2][1]
		
		var lut_out = []
		var step = (t2-t1)/5.0
		
		if step < span:
			break
		
		lut_out.append(_lut[i1])
		for j in range(1, 4):
			var test_t = t1 + j * step
			var new_point = _quadratic_bezier(start_position.position, middle_position.position, end_position.position, test_t)
			var point_dist = point.distance_to(new_point)
			if point_dist < dist:
				dist = point_dist
				point_on_curve = new_point
				return_t = test_t
				index = j
			lut_out.append([new_point, t1 + j * step])
		lut_out.append(_lut[i2])
		
		_lut = lut_out.duplicate()
		count += 1
	if send_time:
		return [point_on_curve, return_t]
	return point_on_curve

func direction_at(point: Vector3):
	var arr = project_point(point, true)
	var t = arr[1]
	var t1 = t+0.01
	var t2 = t-0.01 # it could lead to bounding issues, verify if it's fine to leave it as is
	var p1 = get_point(t1)
	var p2 = get_point(t2)
	
	return (p2 - point + point - p1).normalized()
	

func calculate_lut(resolution = 20, change_resolution = true) -> void:
	lut.clear()
	lut = generate_lut(resolution)
	if change_resolution:
		current_resolution = resolution

func generate_lut(res = 20):
	if not (is_instance_valid(start_position) and is_instance_valid(middle_position) and is_instance_valid(end_position)):
		return
	var _lut = []
	var t = 0
	for i in range(res+1):
		t = i/float(res)
		var position = _quadratic_bezier(start_position.position, middle_position.position, end_position.position, t)
		_lut.append([position, t])
	return _lut

func hull(t):
	var list = []
	var _positions = positions.duplicate()
	list.append_array(positions)
	while positions.size() > 1:
		var _p = []
		for i in range(positions.size()-1):
			var pt = lerp(positions[i], positions[i+1], t)
			list.append(pt)
			_p.push_back(pt)
		positions = _p.duplicate()
	positions = _positions
	return list
	
func average_dir(from_int, to_int):
	var avg_dir = from_int.direction_to(middle_position) + middle_position.direction_to(to_int)
	print(avg_dir.normalized())
	return avg_dir.normalized()

func direction_from(from: int) -> Vector3:
	match from:
		DirectionFrom.START:
			return _average_direction(start_position.intersection, middle_position.intersection)
		DirectionFrom.END:
			return _average_direction(end_position.intersection, middle_position.intersection)
		_:
			return Vector3.ONE * NAN

func direction_from_intersection(intersection: RoadIntersectionNode):
	match intersection:
		start_position:
			return start_position.direction_to(middle_position)
		end_position:
			return end_position.direction_to(middle_position)
		middle_position:
			return average_dir(start_position, end_position)
		_:
			return .direction_from_intersection(intersection)

func _delete():
	middle_position.delete_node()

func set_owner(road_net):
	.set_owner(road_net)
	if road_net:
		middle_position.road_network = road_net

func get_lerp_func():
	return funcref(self, 'interpolate')

func interpolate(start_position, middle_position, end_position, t):
	return _quadratic_bezier(start_position, middle_position, end_position, t)
#
#func split_at_position(position: RoadIntersection) -> Array:
#	var seg_1 = get_script().new(self.start_position.intersection, position, road_network_info, direction)
#	var seg_2 = get_script().new(position, self.end_position.intersection, road_network_info, direction)
#	var road_net = self.road_network
#	print(self.start_position, position, self.end_position)
#	seg_1 = road_net.create_segment(seg_1)
#	seg_2 = road_net.create_segment(seg_2)
#	self.road_network.delete_segment(self)
#	self.call_deferred('free')
#	seg_1.recalculate_offset()
#	seg_2.recalculate_offset()
#
#	return [seg_1, seg_2]


func split_at_position(position: RoadIntersection):
	var arr = project_point(position.position, true)
	var t = arr[1]
	var ab = lerp(start_position.position, middle_position.position, t)
	var bc = lerp(middle_position.position, end_position.position, t)
	var p = lerp(ab, bc, t)
	
	var ab_road = RoadIntersection.new(ab, road_network_info)
	var bc_road = RoadIntersection.new(bc, road_network_info)
	
	var seg_1 = get_script().new(start_position.intersection, ab_road, position, road_network_info, direction)
	var seg_2 = get_script().new(position, bc_road, end_position.intersection, road_network_info, direction)
	
	seg_1 = road_network.create_segment(seg_1)
	seg_2 = road_network.create_segment(seg_2)
	road_network.delete_segment(self)
	self.call_deferred('free')
	
	seg_1.recalculate_offset()
	seg_2.recalculate_offset()
	return [seg_1, seg_2]
	
