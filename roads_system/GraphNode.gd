extends Spatial
class_name GraphResourceNode

const Graph = preload("res://roads_system/Graph.gd")
var graph: Graph

func _ready():
	graph = Graph.new()

func add_point(id: int, point: Vector3) -> Vector3:
	return graph.add_point(id, point)

func remove_point(id: int) -> void:
	graph.remove_point(id)

func get_point(id: int) -> Vector3:
	return graph.get_point(id)

func has_point(id: int) -> bool:
	return graph.has_point(id)

func connect_points(from_id: int, to_id: int, mid_id = null, bidrectional: bool = true) -> Dictionary:
	return graph.connect_points(from_id, to_id, mid_id, bidrectional)

func disconnect_points(from_id: int, to_id: int, mid_id = null):
	return graph.disconnect_points(from_id, to_id, mid_id)

func are_points_connected(from_id: int, to_id: int, mid_id = null, birectional: bool = true):
	return graph.are_points_connected(from_id, to_id, mid_id, birectional)

func get_segment(from_id: int, to_id: int, mid_id = null, birectional: bool = true) -> Dictionary:
	return graph.get_segment(from_id, to_id, mid_id, birectional)
