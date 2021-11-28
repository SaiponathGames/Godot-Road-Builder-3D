extends Resource

signal graph_changed
	
var points = {}
var connections = {}

func add_point(id: int, point: Vector3) -> Vector3:
	points[id] = point
	_emit_graph_changed()
	return points[id]

func remove_point(id: int) -> void:
	points.erase(id)
	_emit_graph_changed()

func get_point(id: int) -> Vector3:
	if not has_point(id):
		push_error("Condition !has_point is true.")
		return Vector3.ONE * NAN
	return points[id]

func has_point(id: int) -> bool:
	return points.keys().has(id)

func connect_points(from_id, to_id, mid_id = null, bidirectional: bool = true) -> Dictionary:
	if are_points_connected(from_id, to_id, mid_id, bidirectional):
		push_error("Condition are_points_connected is true")
		return {}
		
	if mid_id:
		connections[[from_id, mid_id, to_id]] = {"from_id": from_id, "to_id": to_id, "mid_id": mid_id, 'bidirectional': bidirectional, "seg_id": from_id-to_id}
		_emit_graph_changed()
		return connections[[from_id, mid_id, to_id]]
	
	connections[[from_id, to_id]] = {"from_id": from_id, "to_id": to_id, 'bidrectional': bidirectional, "seg_id": from_id-to_id}
	_emit_graph_changed()
	return connections[[from_id, to_id]]

func disconnect_points(from_id, to_id, mid_id = null) -> void: # void
	if not are_points_connected(from_id, to_id):
		push_error("Condition are_points_connected is true")
		return
	
	if mid_id:
		connections.erase([from_id, mid_id, to_id])
		_emit_graph_changed()
		return
	
	connections.erase([from_id, to_id])
	_emit_graph_changed()

func get_segment(from_id, to_id, mid_id = null, bidirectional: bool = true) -> Dictionary:
	if not are_points_connected(from_id, to_id, mid_id, bidirectional):
		push_error('Condition !are_points_connected is true.')
		return {}
	
	return _get_segment(from_id, to_id, mid_id, bidirectional)
	

## Without check, do not call from outside this script!!!!!
func _get_segment(from_id, to_id, mid_id = null, bidirectional: bool = true) -> Dictionary:
	if bidirectional:
		if mid_id:
			return connections.get([from_id, mid_id, to_id], connections.get([to_id, mid_id, from_id], {}))
#		print(connections.get([from_id, to_id], connections.get([to_id, from_id], {})))
		return connections.get([from_id, to_id], connections.get([to_id, from_id], {}))
	
	if mid_id:
		return connections.get([from_id, mid_id, to_id], {})
	return connections.get([from_id, to_id], {})
	

func are_points_connected(from_id, to_id, mid_id = null, bidirectional: bool = true) -> bool:
	if not from_id in points.keys():
		push_error("Condition !from_id in points is true.")
		return false
	if not to_id in points.keys():
		push_error("Condition !to_id in points is true.")
		return false
	if mid_id:
		if not mid_id in points.keys():
			push_error("Condition !mid_id in points is true")
			return false
	return _get_segment(from_id, to_id, mid_id, bidirectional).hash() != {}.hash()

func _emit_graph_changed() -> void:
	emit_signal("graph_changed")
