extends Reference
class_name RoadIntersectionNode

var position: Vector3
var offset: Vector2 setget set_offset

var intersection # RoadIntersection
var segment # RoadSegmentBase

func _init(_intersection, _segment):
	intersection = _intersection
	segment = _segment
	position = _intersection.position

func distance_to(to_intersection: RoadIntersectionNode):
	return self.position.distance_to(to_intersection.position)

func direction_to(_intersection: RoadIntersectionNode):
	return self.position.direction_to(_intersection.position)

func get_left_vertex():
	var direction = segment.direction_from_intersection(self)
	var left = Vector3(-direction.z, direction.y, direction.x).normalized()
	return position + left * segment.road_network_info.width/2
	

func get_right_vertex():
	var direction = segment.direction_from_intersection(self)
	var left = Vector3(-direction.z, direction.y, direction.x).normalized()
	return position + -left * segment.road_network_info.width/2

func set_offset(value: Vector2):
	offset = value
	update_position()
	
func update_position():
	var direction = segment.direction_from_intersection(self) 
	position += direction * offset.y
	position += Vector3(-direction.z, direction.y, direction.x).normalized() * offset.x

func delete_node():
	intersection.delete_node(self)
	
