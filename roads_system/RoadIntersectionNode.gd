extends Object
class_name RoadIntersectionNode

var position: Vector3 = Vector3.ZERO
var offset: Vector2 = Vector2(NAN, NAN) setget set_offset
var direction: Vector3

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

func set_owner(road_net):
	road_network = road_net
	if road_net:
		id = intersection.id + segment.id
	set_offset(Vector2(NAN, NAN))

func distance_to(to_intersection: RoadIntersectionNode):
	return self.position.distance_to(to_intersection.position)

func direction_to(_intersection: RoadIntersectionNode):
	return self.position.direction_to(_intersection.position)

func get_left_vertex():
	var direction = segment.direction_from_intersection(self)
	var left = Vector3(-direction.z, direction.y, direction.x).normalized()
	return position + left * segment.road_network_info.segment_width/2

func get_right_vertex():
	var direction = segment.direction_from_intersection(self)
	var left = Vector3(-direction.z, direction.y, direction.x).normalized()
	return position + -left * segment.road_network_info.segment_width/2

func set_offset(value: Vector2):
	if is_vec_nan(value):
		offset.y = calculate_offset()
		offset.x = 0
		update_position()
	else:
		offset = value
		update_position()
	print(offset)

func update_position():
	direction = segment.direction_from_intersection(self) 
	print(position)
	position += direction * offset.y
	position += Vector3(-direction.z, direction.y, direction.x).normalized() * offset.x

func delete_node():
	if is_instance_valid(intersection):
		intersection.delete_node(self)
	call_deferred('free')

func _notification(what):
	match what:
		NOTIFICATION_PREDELETE:
			if is_instance_valid(segment):
				prints("About to be deleted RoadIntersectionNode", "IntersectionNode ID:", id, "Segment ID:", segment.id, 'RoadNetwork:', road_network)
			elif is_instance_valid(intersection):
				prints("About to be deleted RoadIntersectionNode", "IntersectionNode ID:", id, "Intersection ID:", intersection.id, 'RoadNetwork:', road_network)
			elif is_instance_valid(segment) and is_instance_valid(intersection):
				prints("About to be deleted RoadIntersectionNode", "IntersectionNode ID:", id, "Intersection ID:", intersection.id, "Segment ID:", segment.id, 'RoadNetwork:', road_network)
			else:
				prints("About to be deleted RoadIntersectionNode", "IntersectionNode ID:", id, 'RoadNetwork:', road_network)

func calculate_offset():
	var c = intersection.road_network_info.intersection_curvature
	var l = intersection.road_network_info.intersection_length
	var n = intersection.get_connected_nodes().size()
	var w = segment.road_network_info.segment_width
	return c + l + (n * w) * c

func is_vec_nan(vec) -> bool:
	if typeof(vec) == TYPE_VECTOR3:
		return is_nan(vec.x) and is_nan(vec.y) and is_nan(vec.z)
	if typeof(vec) == TYPE_VECTOR2:
		return is_nan(vec.x) and is_nan(vec.y)
	if typeof(vec) == TYPE_REAL:
		return is_nan(vec)
	return false
