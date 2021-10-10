extends Node
class_name GraphResource

signal graph_changed

class Point:
	var position: Vector3
	
	func _init(p_position: Vector3):
		self.position = p_position
		
class Segment:
	var start_position: Vector3
	var end_position: Vector3
	
	func _init(p_start_position, p_end_position):
		self.start_position = p_start_position
		self.end_position = p_end_position
	
var points = {}
var network = {}

func add_point(id: int, point: Vector3) -> Point:
	points[id] = Point.new(point)
	return points[id]

func remove_point(id: int) -> void:
	points.erase(id)

func get_point(id: int) -> Vector3:
	if not has_point(id):
		push_error("Condition !has_point is true.")
		return Vector3.ONE * NAN
	return points[id].position

func has_point(id: int) -> bool:
	return points.keys().has(id)

func connect_points(from_id, to_id) -> Segment:
	if are_points_connected(from_id, to_id):
		push_error("Condition are_points_connected is true")
		return null
	
	network[[from_id, to_id]] = Segment.new(get_point(from_id), get_point(to_id))
	return network[[from_id, to_id]]

func disconnect_points(from_id, to_id) -> void: # void
	if not are_points_connected(from_id, to_id):
		push_error("Condition !are_points_connected is true")
		return
	
	network.erase([from_id, to_id])

func are_points_connected(from_id, to_id):
	if not from_id in points.keys():
		push_error("Condition !from_id in points is true.")
		return false
	if not to_id in points.keys():
		push_error("Condition !to_id in points is true.")
		return false
