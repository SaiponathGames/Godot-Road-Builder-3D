extends Spatial
class_name GraphResourceNode

signal graph_changed

const Graph = preload("res://roads_system/Graph.gd")
var graph: Graph

func _ready():
	graph = Graph.new()
	graph.connect("graph_changed", self, "_on_Graph_res_changed")

func add_point(id: int, point: Vector3) -> Vector3:
	return graph.add_point(id, point)

func remove_point(id: int) -> void:
	graph.remove_point(id)

func get_point(id: int) -> Vector3:
	return graph.get_point(id)

func has_point(id: int) -> bool:
	return graph.has_point(id)

func connect_points(from_id: int, to_id: int, seg_id: int, bidrectional: bool = true) -> Dictionary:
	return graph.connect_points(from_id, to_id, seg_id, bidrectional)

func disconnect_points(from_id: int, to_id: int, seg_id):
	return graph.disconnect_points(from_id, to_id, seg_id)

func are_points_connected(from_id: int, to_id: int, birectional: bool = true):
	return graph.are_points_connected(from_id, to_id, birectional)

func get_segment(from_id: int, to_id: int, seg_id, birectional: bool = true) -> Dictionary:
	return graph.get_segment(from_id, to_id, seg_id, birectional)

func get_all_segments_from_to(from_id, to_id) -> Array:
	return graph.get_all_segments_from_to(from_id, to_id)

func are_points_connected_with_segment(from_id, to_id, seg_id, bidrectional: bool = true):
	return graph.are_points_connected_with_segment(from_id, to_id, seg_id, bidrectional)

func get_all_segments():
	return graph.get_all_segments()

func get_all_intersections():
	return graph.get_all_intersections()

func _on_Graph_res_changed():
	emit_signal("graph_changed")
