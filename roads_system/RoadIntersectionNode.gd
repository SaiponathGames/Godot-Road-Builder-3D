extends Object
class_name RoadIntersectionNode

var position: Vector3
var offset: Vector2 setget set_offset

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
	offset = value
	update_position()
	
func update_position():
	var direction = segment.direction_from_intersection(self) 
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
				prints("About to be deleted RoadIntersectionNode", "IntersectionNode ID: ", id, "Segment ID:", segment.id)
			elif is_instance_valid(intersection):
				prints("About to be deleted RoadIntersectionNode", "IntersectionNode ID: ", id, "Intersection ID:", intersection.id)
			elif is_instance_valid(segment) and is_instance_valid(intersection):
				prints("About to be deleted RoadIntersectionNode", "IntersectionNode ID: ", id, "Intersection ID:", intersection.id, "Segment ID:", segment.id)
			else:
				prints("About to be deleted RoadIntersectionNode", "IntersectionNode ID: ", id)
