extends RoadSegmentBase
class_name RoadSegmentLinear


func _init(_start_position, _end_position, _road_net_info, _direction).(_start_position, _end_position, _road_net_info, _direction):
	pass

func project_point(to_position: Vector3):
	return Geometry.get_closest_point_to_segment(to_position, start_position.position, end_position.position)

func get_aabb() -> AABB:
	var aabb: AABB
	if int(start_position.position.x) == int(end_position.position.x):
		if int(start_position.position.z) == int(end_position.position.z):
			return AABB()
		else:
			aabb = AABB(start_position.position + (Vector3(1, 0, 1)), Vector3(1, 0, 1))
			aabb.end = end_position.position - (Vector3(1, 0, 1))
	elif int(start_position.position.z) == int(end_position.position.z):
		aabb =  AABB(start_position.position + (Vector3(1, 0, 1)), Vector3(1, 0, 1))
		aabb.end = end_position.position - (Vector3(1, 0, 1))
	else:
		aabb = AABB(start_position.position, Vector3(1, 0, 1))
		aabb.end = end_position.position
	return aabb

func get_point(t):
	return start_position.linear_interpolate(end_position, t)

func get_length():
	return start_position.distance_to(end_position)

func split_at_position(position) -> Array:
	self.road_network.delete_segment(self)
	var seg_1 = get_script().new(self.start_position, position, road_network_info, direction)
	var seg_2 = get_script().new(position, self.end_position, road_network_info, direction)
	
	seg_1 = self.road_network.create_segment(seg_1)
	seg_2 = self.road_network.create_segment(seg_2)
	
	return [seg_1, seg_2]
	
