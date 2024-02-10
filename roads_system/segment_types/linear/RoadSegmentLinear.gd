extends RoadSegmentBase
class_name RoadSegmentLinear


func _init(_start_position, _end_position, _road_net_info, _direction).(_start_position, _end_position, _road_net_info, _direction):
	seg_type = 1
	modder_id = 0
	custom_id = 0
	

func project_point(to_position: Vector3):
	return Geometry.get_closest_point_to_segment(to_position, start_position.position, end_position.position)


func get_aabb() -> AABB:
	var aabb: AABB
	var r = road_network_info.segment_width * 0.5
	
	var min_vector = min_vec(start_position.position, end_position.position)-(Vector3.ONE * r)
	var max_vector = max_vec(start_position.position, end_position.position)+(Vector3.ONE * r)
#	var min_vector = Vector3(min(start_position.position.x, end_position.position.x)-r, min(start_position.position.y, end_position.position.y)-r, min(start_position.position.z, end_position.position.z)-r)
#	var max_vector = Vector3(max(start_position.position.x, end_position.position.x)+r, max(start_position.position.y, end_position.position.y)+r, max(start_position.position.z, end_position.position.z)+r)
	aabb = AABB(min_vector, Vector3.ONE)
	aabb.end = max_vector
	
	return aabb
	

func min_vec(a, b):
	return Vector3(min(a.x, b.x), min(a.y, b.y), min(a.z, b.z))

func max_vec(a, b):
	return Vector3(max(a.x, b.x), max(a.y, b.y), max(a.z, b.z))

func get_lerp_func():
	return funcref(self, 'interpolate')

func interpolate(_start_position, _end_position, t):
	return lerp(_start_position, _end_position, t)

func get_point(t):
	return interpolate(start_position.position, end_position.position, t)

func get_length():
	if not (is_instance_valid(start_position) or is_instance_valid(end_position)):
		return 0
	return start_position.distance_to(end_position)

func _delete():
	start_position.delete_node()
	end_position.delete_node()

func _average_direction(road_intersection: RoadIntersection, position: RoadIntersection):
	return road_intersection.direction_to(position)

func split_at_position(position: RoadIntersection) -> Array:
	var seg_1 = get_script().new(self.start_position.intersection, position, road_network_info, direction)
	var seg_2 = get_script().new(position, self.end_position.intersection, road_network_info, direction)
	var road_net = self.road_network
	print(self.start_position, position, self.end_position)
	seg_1 = road_net.create_segment(seg_1)
	seg_2 = road_net.create_segment(seg_2)
	self.road_network.delete_segment(self)
	self.call_deferred('free')
	
	return [seg_1, seg_2]
