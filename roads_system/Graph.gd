extends Resource

signal graph_changed
	
var points = {}
var connections = {}
var edges = {}

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

func connect_points(from_id: int, to_id: int, seg_id: int, bidirectional: bool = true) -> Dictionary:
	if are_points_connected_with_segment(from_id, to_id, seg_id, bidirectional):
		push_error("Condition are_points_connected is true")
		return {}
	
	var from_to_id = _get_from_to_id(from_id, to_id)
	if typeof(connections.get(from_to_id)) == TYPE_ARRAY:
		connections[from_to_id].append(seg_id)
	else:
		connections[from_to_id] = [seg_id]
	edges[seg_id] = {"from_id": from_id, "to_id": to_id, "seg_id": seg_id, "bidirectional": bidirectional}
	_emit_graph_changed()
	return edges[seg_id]

func disconnect_points(from_id: int, to_id: int, seg_id: int) -> void: # void
	if not are_points_connected_with_segment(from_id, to_id, seg_id):
		push_error("Condition !are_points_connected is true")
		return
#
	edges.erase(seg_id)
	connections.erase(_get_from_to_id(from_id, to_id))
	_emit_graph_changed()

func get_segment(from_id: int, to_id: int, seg_id: int, bidirectional: bool = true) -> Dictionary:
	if !are_points_connected(from_id, to_id, bidirectional):
		push_error("Condition are_points_connected is true")
		return {}
	
	if edges.has(seg_id) and are_points_connected_with_segment(from_id, to_id, seg_id):
		return edges[seg_id]
	push_error("Condition !edges.has(seg_id) is true")
	return {}

func are_points_connected(from_id: int, to_id: int, _bidirectional: bool = true) -> bool:
	if not from_id in points.keys():
		push_error("Condition !from_id in points is true.")
		return false
	if not to_id in points.keys():
		push_error("Condition !to_id in points is true.")
		return false
	return connections.has(_get_from_to_id(from_id, to_id))

func are_points_connected_with_segment(from_id: int, to_id: int, seg_id: int, bidirectional: bool = true):
	if !are_points_connected(from_id, to_id, bidirectional):
		return false
	
	return connections.get(_get_from_to_id(from_id, to_id), []).has(seg_id)

func get_all_segments_from_to(from_id: int, to_id: int, bidirectional: bool = true) -> Array:
	if !are_points_connected(from_id, to_id, bidirectional):
		push_error("Condition !are_points_connected(from_id, to_id) is true")
		return []
	var segments = []
	for seg_id in connections.get(_get_from_to_id(from_id, to_id), []):
		segments.append(edges.get(seg_id))
	return segments

func get_all_segments():
	return edges.values()
		
func _emit_graph_changed() -> void:
	emit_signal("graph_changed")

func _get_from_to_id(from_id: int, to_id: int, from_id_bits: int = 18):
		return int((from_id << from_id_bits) | to_id)
