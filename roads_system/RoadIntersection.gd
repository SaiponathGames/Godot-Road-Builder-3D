extends Reference
class_name RoadIntersection


var position

var connections: Array = []
var visible_connections: Array = []

var road_network
var road_network_info
var visible = true

func _init(_position, _road_net_info):
	self.position = _position
	self.road_network_info = _road_net_info

func set_connections(_connections):
	self.connections = _connections

func set_owner(road_net):
	self.road_network = road_net

func update_visiblity_connections():
	visible_connections.clear()
	for connection in connections:
		if connection.visible:
			visible_connections.append(connection)

func get_connected_nodes():
	var connected_nodes = []
	for connection in connections:
		connected_nodes.append(connection.end_position)
	return connected_nodes

# shorthands
func distance_to(to_intersection: RoadIntersection):
	return self.position.distance_to(to_intersection.position)

func direction_to(to_intersection: RoadIntersection):
	return self.position.direction_to(to_intersection.position)

func linear_interpolate(to_intersection: RoadIntersection, time):
	return self.position.linear_interpolate(to_intersection.position, time)

func angle_to(to_intersection: RoadIntersection):
	return self.position.angle_to(to_intersection.position)

func get_aabb() -> AABB:
	return AABB(
		(Vector3.ONE * -0.25)+position, 
		Vector3.ONE * 0.5
	)
