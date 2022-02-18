extends RoadSegmentBase
class_name RoadSegmentBezier


var middle_position: RoadIntersectionNode

var lut = []

var current_resolution setget set_current_resolution

func _init(_start_position, _middle_position, _end_position, _road_net_info, _direction).(_start_position, _end_position, _road_net_info, _direction):
	self.middle_position = _middle_position.create_node(self)
	calculate_lut()
	modder_id = 0
	seg_type = 2
	custom_id = (5.625)*rad2deg(middle_position.intersection.angle_to(start_position.intersection))+rad2deg(middle_position.intersection.angle_to(end_position.intersection))
	positions.append(_middle_position)
	
func set_current_resolution(value):
	current_resolution = value
	calculate_lut(value, false)

func _quadratic_bezier(p0: Vector3, p1: Vector3, p2: Vector3, t: float):
	var q0 = p0.linear_interpolate(p1, t)
	var q1 = p1.linear_interpolate(p2, t)
	return q0.linear_interpolate(q1, t)

func get_length(resolution = 16):
	if current_resolution != resolution:
		calculate_lut(resolution, false)
	var sum = 0
	var previous_point = start_position.position
	for point_t in lut:
		var point = point_t[0]
		sum += previous_point.distance_to(point)
		previous_point = point
	return sum

func get_point(t) -> Vector3:
	return _quadratic_bezier(start_position.position, middle_position.position, end_position.position, t)

func get_aabb():
	var minima = Vector3.INF
	var maxima = -Vector3.INF
	for point_t in lut:
		var point = point_t[0]
		minima = Vector3(min(minima.x, point.x), min(minima.y, point.y), min(minima.z, point.z))
		maxima = Vector3(max(maxima.x, point.x), max(maxima.y, point.y), max(maxima.z, point.z))
	var aabb = AABB((minima + maxima)/2, maxima - minima)
	return aabb

func _average_direction(road_intersection: RoadIntersection, position: RoadIntersection):
	var projected_time = project_point(position.position, true)[1]
	var direction = Vector3.ZERO
	for t in range(0, projected_time, 0.01):
		direction += road_intersection.position.direction_to(get_point(t))
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
	var return_t = 0
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


func calculate_lut(resolution = 20, change_resolution = true) -> void:
	var t = 0
	while t <= 0.9:
		t += 1/float(resolution)
		t = clamp(t, 0, 1)
		var position = _quadratic_bezier(start_position.position, middle_position.position, end_position.position, t)
		lut.append([position, t])
	if change_resolution:
		current_resolution = resolution

func hull(t):
	var list = []
	list.append_array(positions)
	while positions.size() > 1:
		var _p = []
		for i in range(positions.size()-1):
			var pt = lerp(positions[i], positions[i+1], t)
			list.append(pt)
			_p.push_back(pt)
		positions = _p.duplicate()
	return list
	
func direction_from_intersection(intersection: RoadIntersectionNode):
	match intersection:
		start_position:
			return _average_direction(start_position.intersection, middle_position.intersection)
		end_position:
			return _average_direction(end_position.intersection, middle_position.intersection)
		_:
			return direction_from_intersection(intersection)

func _delete():
	middle_position.delete_node()
