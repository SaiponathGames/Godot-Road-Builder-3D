extends Object
class_name RoadIntersection


var position: Vector3

var connections: Dictionary = {} # Dictionary[RoadIntersectionNode, RoadSegmentBase]
var visible_connections: Array = []

var road_network
var road_network_info
var visible = true
var renderer = null
var id: int = 0

func _init(_position, _road_net_info):
	self.position = _position
	self.road_network_info = _road_net_info
	renderer = RoadIntersectionRenderer

func set_owner(road_net):
	self.road_network = road_net
	if road_net:
		id = get_id(road_net.min_vector)

func update_visiblity_connections():
	visible_connections.clear()
	for connection in connections.values():
		if connection.visible:
			visible_connections.append(connection)

func get_connected_nodes():
	var connected_nodes = []
	for connection in connections.values():
		connected_nodes.append(connection.end_position)
	return connected_nodes

# shorthands
func distance_to(to_intersection: RoadIntersection):
	return self.position.distance_to(to_intersection.position)

func direction_to(to_intersection: RoadIntersection) -> Vector3:
	return self.position.direction_to(to_intersection.position)

func linear_interpolate(to_intersection: RoadIntersection, time):
	return self.position.linear_interpolate(to_intersection.position, time)

func angle_to(to_intersection: RoadIntersection) -> float:
	return self.position.angle_to(to_intersection.position)

func create_node(road_segment):
	var node = RoadIntersectionNode.new(self, road_segment)
	connections[node] = road_segment
	return node

func delete_node(road_intersection_node):
# warning-ignore:return_value_discarded
	connections.erase(road_intersection_node)

func get_aabb() -> AABB:
	return AABB(
		(Vector3.ONE * -0.25)+position, 
		Vector3.ONE * 0.5
	)

func get_id(_min_vec: Vector3 = Vector3()):
	var p_min
	if _min_vec == Vector3():
		p_min = (road_network.min_vector.x + road_network.min_vector.y + road_network.min_vector.z)
	else:
		p_min = (_min_vec.x + _min_vec.y + _min_vec.z)
	return int((position.x + + position.z * -(p_min) + position.y * -(p_min*p_min) - pow(p_min, 3)))

func duplicate():
	var clone = get_script().new(self.position, self.connections)
	return clone

func _notification(what):
	match what:
		NOTIFICATION_PREDELETE:
			prints("About to be deleted RoadIntersection Intersection ID:", id)

