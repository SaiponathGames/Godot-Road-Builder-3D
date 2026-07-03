extends Object
class_name RoadIntersection


var position: Vector3

var connections: Dictionary = {} # Dictionary[RoadIntersectionNode, RoadSegmentBase]
var visible_connections: Array = []

var _ordered_connections: Dictionary = {} # Dictionary[RoadIntersectionNode, RoadSegmentBase]

var road_network
var road_network_info
var visible = true
var renderer = null
var id: int = 0
var sorter: CustomSorter

func _init(_position, _road_net_info):
	self.position = _position
	self.road_network_info = _road_net_info
	renderer = RoadIntersectionRenderer
	sorter = CustomSorter.new(self, "sort_by_angle", [self])
	

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

func update_offsets():
	_ordered_connections = sorter.sort_dict(connections.duplicate())
	var con_idx = 0
	for connection in _ordered_connections:
		connection.set_offset(Vector2.ONE * NAN, con_idx)
		con_idx += 1

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
	var clone = get_script().new(self.position, self.road_network_info)
	return clone

func _notification(what):
	match what:
		NOTIFICATION_PREDELETE:
			prints("About to be deleted RoadIntersection Intersection ID:", id, "RoadNetwork:", road_network)

func sort_by_angle(a, b, origin):
	var a_position = a.start_position.intersection.position if a.end_position.intersection == origin else a.end_position.intersection.position
	var b_position = b.start_position.intersection.position if b.end_position.intersection == origin else b.end_position.intersection.position
	var a_offset = a_position - origin.position
	var b_offset = b_position - origin.position

	var angle_1 = atan2(a_offset.x, a_offset.z)
	var angle_2 = atan2(b_offset.x, b_offset.z)

	if angle_1 > angle_2:
		return true
	
	if angle_1 < angle_2:
		return false

	return a_offset.length_squared() > b_offset.length_squared()
