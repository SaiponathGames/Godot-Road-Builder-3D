extends Node


class RoadIntersectionVertex:
	var start_points = []
	
	func add_point(point):
		start_points.append(point)

class RoadIntersectionStartPoint:
	var start_point: Vector3
	var v1: Vector3
	var v2: Vector3
	var angle: float
	var intersection: RoadNetwork.RoadIntersection
	
	func _init(_start_point: Vector3):
		self.start_point = _start_point
	
	func generate_vertices(left, connection):
		v1 = start_point + left * connection.width * 0.5
		v2 = start_point + -left * connection.width * 0.5
	
	func calculate_angle():
		pass
