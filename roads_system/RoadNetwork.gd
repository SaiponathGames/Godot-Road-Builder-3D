extends Spatial
class_name RoadNetwork

signal graph_changed()

enum Direction {FORWARD, BACKWARD}

class RoadIntersection:
	
	signal position_changed(before_position, position)
	
	var position: Vector3 setget set_position
	var connections: Array
	var visible_connections: Array
	var length: float = 1
	
	var road_network: RoadNetwork
	var road_network_info: RoadNetworkInfo
	var visible = true
	
	func _init(_position, _road_net_info: RoadNetworkInfo, _connections = []):
		self.position = _position
		self.connections = _connections
		self.length = _road_net_info.length
		self.road_network_info = _road_net_info
	
	func update_visiblity_connections():
		visible_connections = []
		for connection in connections:
			if connection.visible:
				visible_connections.append(connection)
	
	func set_position(value: Vector3):
		var before_position = position
		position = value
		if before_position and position:
			emit_signal("position_changed", before_position, position)
		
	func distance_to(to_intersection: RoadIntersection):
		return self.position.distance_to(to_intersection.position)
	
	func direction_to(to_intersection: RoadIntersection):
		return self.position.direction_to(to_intersection.position)
	
	func linear_interpolate(to_intersection: RoadIntersection, time):
		return self.position.linear_interpolate(to_intersection.position, time)
	
	func get_connected_nodes():
		var connected_nodes = []
		for connection in connections:
			connected_nodes.append(connection.end_position)
		return connected_nodes
	
	func angle_to(to_intersection: RoadIntersection):
		return self.position.angle_to(to_intersection.position)

class RoadNetworkInfo extends Resource:
	export var name: String
	export var id: String
	export var lanes = [] # Array[RoadLaneInfo]
	export var length: float = 1
	export var width: float = 0.5
	export var end_radius: float = 0.5
	export var curvature: float = 0.3
	export var subdivide_length = 5.0
	
	func _init(_id: String, _name: String, _length: float, _width: float, _end_radius: float, _curvature: float = 0.3, _subdivide_length = 5, lanes = []):
		self.id = _id
		self.name = _name
		self.length = _length
		self.width = _width
		self.end_radius = _end_radius
		self.curvature = _curvature
		self.subdivide_length = _subdivide_length
	
	func create_intersection(position: Vector3) -> RoadIntersection:
		return RoadIntersection.new(position, self)
	
class RoadSegment:
	var start_position: RoadIntersection
	var end_position: RoadIntersection
	var distance: float
	
	var road_network: RoadNetwork
	var road_network_info: RoadNetworkInfo
	var lanes = [] # Array[RoadLanes]
	var width = 0.5
	var visible = true
	
	func _init(_start_position: RoadIntersection, _end_position: RoadIntersection, _road_network: RoadNetwork, _road_net_info: RoadNetworkInfo):
		self.start_position = _start_position
		self.end_position = _end_position
		self.road_network = _road_network
		self.road_network_info = _road_net_info
		self.width = road_network_info.width
		self.distance = start_position.distance_to(end_position)
		self.instance_lanes()
	
	func instance_lanes():
		for lane in self.road_network_info.lanes:
			lanes.append(lane.instance(self))
	
	func distance_to(to_position: Vector3):
		var closest_point = project_point(to_position)
		return closest_point.distance_to(to_position)
	
	func distance_squared_to(to_position: Vector3):
		var closest_point = project_point(to_position)
		return closest_point.distance_squared_to(to_position)
	
	func direction_to(to_position: Vector3):
		var closest_point = project_point(to_position)
		return closest_point.direction_to(to_position)
	
	func project_point(to_position: Vector3):
		return Geometry.get_closest_point_to_segment(to_position, start_position.position, end_position.position)
	
	func get_bounds(space_around_bounds = 0.5) -> AABB:
		var aabb: AABB
		if int(start_position.position.x) == int(end_position.position.x):
			if int(start_position.position.z) == int(end_position.position.z):
				return AABB()
			else:
				aabb = AABB(start_position.position + (Vector3(1, 0, 1) * space_around_bounds), Vector3(1, 0, 1))
				aabb.end = end_position.position - (Vector3(1, 0, 1) * space_around_bounds)
		elif int(start_position.position.z) == int(end_position.position.z):
			aabb =  AABB(start_position.position + (Vector3(1, 0, 1) * space_around_bounds), Vector3(1, 0, 1))
			aabb.end = end_position.position - (Vector3(1, 0, 1) * space_around_bounds)
		else:
			aabb = AABB(start_position.position, Vector3(1, 0, 1))
			aabb.end = end_position.position
		aabb.position.y -= space_around_bounds
		aabb.size.y += space_around_bounds
		return aabb
	
	func get_points(spacing = 0.5, resolution = 1):
		var points = [start_position.position]
		var previous_point = start_position.position
		var distance_since_last_point = 0
		var division_amount = distance * resolution * 10
		var time = 0
		while time <= 1:
			time += 1/division_amount
			var point = start_position.linear_interpolate(end_position, time)
			distance_since_last_point += point.distance_to(previous_point)
			while distance_since_last_point >= spacing:
				var over_shoot_distance = distance_since_last_point - spacing
				var new_point = point + (previous_point - point).normalized() * over_shoot_distance
				points.append(new_point)
				distance_since_last_point = over_shoot_distance
				previous_point = new_point
			previous_point = point
		return points

class RoadBezier:
	var start_position: RoadIntersection
	var middle_position: RoadIntersection
	var end_position: RoadIntersection
	
	var distance = 0
	
	var lut = []
	
	var road_network: RoadNetwork
	var road_network_info: RoadNetworkInfo
	var width = 0.5
	var visible = true
	var current_resolution setget set_current_resolution
	
	func _init(p_start_position, p_middle_position, p_end_position, p_road_net_info: RoadNetworkInfo, p_road_network: RoadNetwork):
		self.start_position = p_start_position
		self.middle_position = p_middle_position
		self.end_position = p_end_position
		self.road_network_info = p_road_net_info
		self.road_network = p_road_network
		calculate_lut()
		self.distance = get_distance()
		
	func set_current_resolution(value):
		current_resolution = value
		calculate_lut(value, false)
	
	func quadratic_bezier(p0: Vector3, p1: Vector3, p2: Vector3, t: float):
		var q0 = p0.linear_interpolate(p1, t)
		var q1 = p1.linear_interpolate(p2, t)
		return q0.linear_interpolate(q1, t)
	
	func get_distance(resolution = 16):
		if current_resolution != resolution:
			calculate_lut(resolution, false)
		var sum = 0
		var previous_point = start_position.position
		for point_t in lut:
			var point = point_t[0]
			sum += previous_point.distance_to(point)
			previous_point = point
		return sum

	func distance_to(position: Vector3):
		var closest_point = project_point(position)
		return closest_point.distance_to(position)
		
	func distance_squared_to(position: Vector3):
		var closest_point = project_point(position)
		return closest_point.distance_squared_to(position)
	
	func direction_to(position: Vector3):
		var closest_point = project_point(position)
		return closest_point.direction_to(position)
	
	func get_point(t) -> Vector3:
		return quadratic_bezier(start_position.position, middle_position.position, end_position.position, t)
	
	func get_bounds():
		var minima = Vector3.INF
		var maxima = -Vector3.INF
		for point_t in lut:
			var point = point_t[0]
			minima = Vector3(min(minima.x, point.x), min(minima.y, point.y), min(minima.z, point.z))
			maxima = Vector3(max(maxima.x, point.x), max(maxima.y, point.y), max(maxima.z, point.z))
		var aabb = AABB((minima + maxima)/2, maxima - minima)
		return aabb
	
	func project_point(position: Vector3, send_time = false):
		var i = 0
		var min_dist = INF
		var k = 0
		for point_t in lut:
			var dist = position.distance_to(point_t[0])
			if dist < min_dist:
				min_dist = dist
				i = k
			k += 1
		
		return refine_binary(position, i, send_time)
	
	func refine_binary(point: Vector3, index: int, send_time = false,  max_iters = 25, span = 0.001):
		var _lut = self.lut.duplicate()
		var count = 0
		var dist = INF
		var point_on_curve = _lut[index][0]
		var return_t = 0
		while count < max_iters:
			var i1 = wrapi(index-1, 0, _lut.size())
			var i2 = wrapi(index+1, 0, _lut.size())
			
			var t1 = _lut[i1][1]
			var t2 = _lut[i2][1]
			
			var lut_out = []
			var step = (t2-t1)/5.0
			
			if step < span:
				break
			
			lut_out.append(_lut[i1])
			for j in range(1, 4):
				var test_t = t1 + j * step
				var new_point = quadratic_bezier(start_position.position, middle_position.position, end_position.position, test_t)
				var point_dist = point.distance_to(new_point)
				if point_dist < dist:
					dist = point_dist
					point_on_curve = new_point
					return_t = test_t
#					prints(return_t, "test")
					index = j
				lut_out.append([new_point, t1 + j * step])
			lut_out.append(_lut[i2])
			
			_lut = lut_out.duplicate()
			count += 1
		if send_time:
#			print(return_t)
			return [point_on_curve, return_t]
		return point_on_curve
	
		
	
	func calculate_lut(resolution = 20, change_resolution = true) -> void:
		var t = 0
		while t <= 0.9:
			t += 1/float(resolution)
			t = clamp(t, 0, 1)
			var position = quadratic_bezier(start_position.position, middle_position.position, end_position.position, t)
			lut.append([position, t])
		if change_resolution:
			current_resolution = resolution

class RoadLane:
	var lane_info: RoadLaneInfo
	var segment: RoadSegment
	
	var start_point: RoadIntersection
	var end_point: RoadIntersection
	
	var road_network: RoadNetwork
	
	func _init(_lane_info: RoadLaneInfo, _segment: RoadSegment):
		self.segment = _segment
		self.start_point = _segment.start_position
		self.end_point = _segment.end_position
		self.road_network = _segment.road_network
	
class RoadLaneInfo extends Resource:
	export var direction: int = Direction.FORWARD
	export var width: float
	export var offset: float
	
	func _init(_direction, _width, _offset):
		self.direction = _direction
		self.width = _width
		self.offset = _offset
	
	func instance(_segment: RoadSegment):
		return RoadLane.new(self, _segment)
		

class RoadLaneIntersection:
	var out_lanes: Array = [] # Array[RoadLane]
	var in_lanes = [] # Array[RoadLane]
	
	
var intersections: Array
var network: Dictionary

export var use_astar = false
var astar: AStar = AStar.new()

export var use_immediate_geo = true
export(NodePath) var immediate_geo_node
var immediate_geo: ImmediateGeometry

export var use_quad_tree = true

export(NodePath) var quad_tree_node_path
var quad_tree: QuadTreeNode

export(NodePath) var quad_tree_edge_node_path
var quad_tree_edge: QuadTreeNode
export(NodePath) var quad_tree_edge_bezier_node_path
var quad_tree_edge_bezier: QuadTreeNode

export var auto_clear_when_draw = true

var astar_intersection_map: Dictionary = {}

func _ready():
	if use_quad_tree:
		quad_tree = get_node(quad_tree_node_path)
	if use_quad_tree:
		quad_tree_edge = get_node(quad_tree_edge_node_path)
	if use_quad_tree:
		quad_tree_edge_bezier = get_node(quad_tree_edge_bezier_node_path)
	if use_immediate_geo:
		immediate_geo = get_node(immediate_geo_node)
	

func add_intersection(intersection: RoadIntersection, do_update: bool = true):
	if intersection.road_network == self:
		push_error("Intersection is already present.")
		return
	elif intersection.road_network:
		push_error("Intersection already in a network, remove it from the previous network and add it to this network.")
		return
	
	var _quad_tree_node = _create_quad_tree_node(intersection)
	if use_quad_tree:
		var qt_node = quad_tree.add_body(_quad_tree_node, _quad_tree_node.get_meta("_aabb"))
		intersection.set_meta("_qt_node", qt_node)
	intersections.append(intersection)
	intersection.road_network = self
	intersection.connect("position_changed", self, "move_intersection", [intersection])
	if use_astar:
		var _intersection_id = _generate_id(intersection.position)
		astar_intersection_map[_intersection_id] = intersection
		astar.add_point(_intersection_id, intersection.position)
	if do_update:
		emit_signal("graph_changed")

func remove_intersection(intersection: RoadIntersection, check_when_remove = false, do_update: bool = true):
	if !intersection.road_network:
		push_error("Intersection not in network.")
		return
	
	if intersection.road_network != self:
		push_error("Can't remove intersection, intersection is in different road network.")
		return
	
	if intersection.connections:
		for connection in intersection.connections:
			if connection is RoadBezier:
				if are_intersections_connected_with_bezier(connection.start_position, connection.middle_position, connection.end_position) or !check_when_remove:
					disconnect_intersections_with_bezier(connection.start_position, connection.middle_position, connection.end_position)
					continue
			if are_intersections_connected(connection.start_position, connection.end_position) or !check_when_remove:
				disconnect_intersections(connection.start_position, connection.end_position, false)

	intersections.erase(intersection)
	intersection.road_network = null
	if use_quad_tree:
		if intersection.has_meta("_qt_node"):
			quad_tree.remove_body(intersection.get_meta("_qt_node"))
	if use_astar:
		var _intersection_id = _generate_id(intersection.position)
		if astar.has_point(_intersection_id):
			astar_intersection_map.erase(_intersection_id)
			astar.remove_point(_intersection_id)
	if do_update:
		emit_signal("graph_changed")

func move_intersection(before_position: Vector3, current_position: Vector3, intersection: RoadIntersection):
	if use_astar:
		var old_id = _generate_id(before_position)
		var new_id = _generate_id(current_position)
		var point_connections = astar.get_point_connections(old_id)
		astar.add_point(new_id, current_position)
		for point in point_connections:
			astar.disconnect_points(old_id, point)
			astar.connect_points(new_id, point)
		astar.remove_point(old_id)
		astar_intersection_map.erase(old_id)
		astar_intersection_map[new_id] = intersection
	

func disconnect_intersections(start_intersection: RoadIntersection, end_intersection: RoadIntersection, do_update: bool = true):
	if !are_intersections_connected(start_intersection, end_intersection):
		push_error("Intersections not connected, connect it before disconnecting.")
		return
	
	var segment = get_connection(start_intersection, end_intersection)
	start_intersection.connections.erase(segment)
	end_intersection.connections.erase(segment)
	if use_astar:
		if astar.has_point(_generate_id(end_intersection.position)) and astar.has_point(_generate_id(end_intersection.position)):
			astar.disconnect_points(_generate_id(start_intersection.position), _generate_id(end_intersection.position))
	if use_quad_tree:
		quad_tree_edge.remove_body(segment.get_meta("_qt_edge"))
	network.erase([start_intersection, end_intersection])
	if do_update:
		emit_signal("graph_changed")

func split_at_postion(segment: RoadSegment, _position: RoadIntersection, road_net_info: RoadNetworkInfo):
	disconnect_intersections(segment.start_position, segment.end_position, false)
	var first_segment = connect_intersections(segment.start_position, _position, road_net_info, false)
	var second_segment = connect_intersections(_position, segment.end_position, road_net_info, false)
	return [first_segment, second_segment]

func _rec_split_at_position(segment: RoadSegment, _position: RoadIntersection, road_net_info: RoadNetworkInfo):
	pass

func hull(segment: RoadBezier, t):
	var list = []
	var positions = [segment.start_position.position, segment.middle_position.position, segment.end_position.position]
	var test_p = []
	list.append_array(positions)
	while positions.size() > 1:
		var _p = []
		for i in range(positions.size()-1):
			var pt = lerp(positions[i], positions[i+1], t)
			list.append(pt)
			_p.push_back(pt)
		positions = _p.duplicate()
	return list
	

func split_at_position_with_bezier(segment: RoadBezier, _position: RoadIntersection, road_net_info: RoadNetworkInfo):
	print("writing", immediate_geo)
	var t = segment.project_point(_position.position, true)[1]
	print(t, "failing..")
	var points = hull(segment, t)
	print(points)
	
	immediate_geo.begin(Mesh.PRIMITIVE_LINES)
	var colors = [Color.darkturquoise, Color.blue, Color.black, Color.darkred, Color.darkgoldenrod, Color.darkgreen]
	var previous_point = points[0]
	var i = 0
	for point in points:
		if previous_point != point:
			print("drawing line", previous_point, point)
			DrawingUtils.draw_line(immediate_geo, previous_point, point, colors[i])
		previous_point = point
		i+=1
	i = 0
	immediate_geo.end()
	for point in points:
		DrawingUtils.draw_empty_circle(immediate_geo, point, 0.125, colors[i])
		i+=1
#	DrawingUtils.draw_empty_circle(immediate_geo, p1, 0.125, Color.black)
#	DrawingUtils.draw_empty_circle(immediate_geo, p2, 0.125, Color.blue)
#	DrawingUtils.draw_empty_circle(immediate_geo, p3, 0.125, Color.darkblue)
#	DrawingUtils.draw_empty_circle(immediate_geo, p4, 0.125, Color.violet)
#	DrawingUtils.draw_empty_circle(immediate_geo, p5, 0.125, Color.magenta)
#
	delete_connection_with_bezier(segment, true, false)
#	var intersection_list = []
#	for point in points:
#		var intersection = road_net_info.create_intersection(point)
#		add_intersection(intersection)
#		intersection_list.append(intersection)
#	emit_signal("graph_changed")
#	var p1_int = road_net_info.create_intersection(p1)
#	var p2_int = road_net_info.create_intersection(p2)
#
#	var p3_int = road_net_info.create_intersection(p3)
#	var p4_int = road_net_info.create_intersection(p4)
#	var p5_int = road_net_info.create_intersection(p5)
#
#	add_intersection(p0_int, false)
#	add_intersection(p1_int, false)
#	add_intersection(p2_int, false)
#
#	add_intersection(p3_int, false)
#	add_intersection(p4_int, false)
#	add_intersection(p5_int, false)
	var left_intersection_list = []
	for _i in [0, 3, 5]:
		var intersection = road_net_info.create_intersection(points[_i])
		if _i == 3:
			intersection.visible = false
		add_intersection(intersection, false)
		left_intersection_list.append(intersection)
	print(left_intersection_list)
	var right_intersection_list = []
	for _i in [2, 4, 5]:
		var intersection = road_net_info.create_intersection(points[_i])
		if _i == 4:
			intersection.visible = false
		add_intersection(intersection, false)
		right_intersection_list.append(intersection)
	
	
	connect_intersections_with_bezier(left_intersection_list[0], left_intersection_list[1], left_intersection_list[2], road_net_info, false)
#	connect_intersections_with_bezier(p5_int, p4_int, p2_int, road_net_info)


func join_segments(segment_1: RoadSegment, segment_2: RoadSegment, network_info: RoadNetworkInfo):
	disconnect_intersections(segment_1.start_position, segment_1.end_position)
	disconnect_intersections(segment_2.start_position, segment_2.end_position)
	var joined_seg = connect_intersections(segment_1.start_position, segment_2.end_position, network_info)
	return joined_seg
	

func are_intersections_connected(start_intersection, end_intersection):
	if start_intersection.road_network != self:
		push_error("Can't connect, please add start_intersection to this road network.")
		return
	if end_intersection.road_network != self:
		push_error("Can't connect, please add end_intersection to this road network.")
		return
	return network.has([start_intersection, end_intersection])
	
func connect_intersections(start_intersection: RoadIntersection, end_intersection: RoadIntersection, road_net_info: RoadNetworkInfo, do_update: bool = true) -> RoadSegment:
	if are_intersections_connected(start_intersection, end_intersection):
		push_error("Intersections already connected, disconnect the intersection and reconnect again.")
	
	var segment = RoadSegment.new(start_intersection, end_intersection, self, road_net_info)
	_set_connection(start_intersection, end_intersection, segment)
#	subdivide_intersections(start_intersection, end_intersection, road_net_info)
	start_intersection.connections.append(segment)
	end_intersection.connections.append(segment)
	if use_astar and _generate_id(start_intersection.position) != _generate_id(end_intersection.position):
		astar.connect_points(_generate_id(start_intersection.position), _generate_id(end_intersection.position))
	if use_quad_tree:
		var qt_edge = _create_quad_tree_edge(segment)
		quad_tree_edge.add_body(qt_edge, qt_edge.get_meta("_aabb"))
		segment.set_meta("_qt_edge", qt_edge)
	if do_update:
		emit_signal("graph_changed")
	return get_connection(start_intersection, end_intersection)

func _rec_connect_intersections(start_intersection: RoadIntersection, end_intersection: RoadIntersection, road_net_info: RoadNetworkInfo, do_update: bool = true, recursive_count: int = 0):
	if are_intersections_connected(start_intersection, end_intersection):
		push_error("Intersections already connected, disconnect the intersection and reconnect again.")
	if recursive_count == 4:
		return
	var segment = RoadSegment.new(start_intersection, end_intersection, self, road_net_info)
	_set_connection(start_intersection, end_intersection, segment)
	subdivide_intersections(start_intersection, end_intersection, road_net_info)
	start_intersection.connections.append(segment)
	end_intersection.connections.append(segment)
	if use_astar and _generate_id(start_intersection.position) != _generate_id(end_intersection.position):
		astar.connect_points(_generate_id(start_intersection.position), _generate_id(end_intersection.position))
	if use_quad_tree:
		var qt_edge = _create_quad_tree_edge(segment)
		quad_tree_edge.add_body(qt_edge, qt_edge.get_meta("_aabb"))
		segment.set_meta("_qt_edge", qt_edge)
	if do_update:
		emit_signal("graph_changed")
	return get_connection(start_intersection, end_intersection)

func find_path(start_intersection, end_intersection):
	if use_astar:
		var shortest_path = astar.get_id_path(_generate_id(start_intersection), _generate_id(end_intersection))
		var intersection_path = []
		for point in shortest_path:
			intersection_path.append(astar_intersection_map[point])
		return intersection_path
	else:
		return []

func connect_intersections_with_bezier(start_intersection: RoadIntersection, middle_intersection: RoadIntersection, end_intersection: RoadIntersection, road_net_info: RoadNetworkInfo, do_update: bool = true):
	if are_intersections_connected_with_bezier(start_intersection, middle_intersection, end_intersection):
		push_error("Intersections already connected, disconnect the intersection and reconnect again.")
		return
	var segment = RoadBezier.new(start_intersection, middle_intersection, end_intersection, road_net_info, self)
	start_intersection.connections.append(segment)
	end_intersection.connections.append(segment)
	middle_intersection.visible = false
	middle_intersection.connections.append(segment)
	
	_set_connection_with_bezier(start_intersection, middle_intersection, end_intersection, segment)
	if use_quad_tree:
		var _qt_bedge = _create_quad_tree_edge(segment)
		quad_tree_edge_bezier.add_body(_qt_bedge, _qt_bedge.get_meta("_aabb"))
		segment.set_meta("_qt_bedge", _qt_bedge)
	if do_update:
		emit_signal("graph_changed")
	return segment

func are_intersections_connected_with_bezier(start_intersection: RoadIntersection, middle_intersection: RoadIntersection, end_intersection: RoadIntersection):
	if start_intersection.road_network != self:
		push_error("Can't connect, please add start_intersection to this road network.")
		return
	if middle_intersection.road_network != self:
		push_error("Can't connect, please add middle_intersection to this road network.")
		return
	if end_intersection.road_network != self:
		push_error("Can't connect, please add end_intersection to this road network.")
		return
	return network.has([start_intersection, middle_intersection, end_intersection])

func disconnect_intersections_with_bezier(start_intersection: RoadIntersection, middle_intersection: RoadIntersection, end_intersection: RoadIntersection, do_update: bool = true):
	if !are_intersections_connected_with_bezier(start_intersection, middle_intersection, end_intersection):
		push_error("Intersections not connected, connect it before disconnecting.")
	var segment = get_connection_with_bezier(start_intersection, middle_intersection, end_intersection)
	start_intersection.connections.erase(segment)
	middle_intersection.connections.erase(segment)
	end_intersection.connections.erase(segment)
	network.erase([start_intersection, middle_intersection, end_intersection])
	if use_quad_tree:
		quad_tree_edge_bezier.remove_body(segment.get_meta("_qt_bedge"))
	if do_update:
		emit_signal("graph_changed")

func upgrade_bezier_connection(start_intersection: RoadIntersection, middle_intersection: RoadIntersection, end_intersection: RoadIntersection, new_road_net_info: RoadNetworkInfo, do_update: bool = true):
	if !are_intersections_connected_with_bezier(start_intersection, middle_intersection, end_intersection):
		push_error("Intersections not connected, please try connecting intersections")
	disconnect_intersections_with_bezier(start_intersection, middle_intersection, end_intersection, false)
	connect_intersections_with_bezier(start_intersection, middle_intersection, end_intersection, new_road_net_info, false)
	
	if do_update:
		emit_signal("graph_changed")
	return get_connection_with_bezier(start_intersection, middle_intersection, end_intersection)

func upgrade_connection(start_intersection: RoadIntersection, end_intersection: RoadIntersection, new_road_net_info: RoadNetworkInfo, do_update: bool = true):
	if !are_intersections_connected(start_intersection, end_intersection):
		push_error("Intersections not connected, please try after connecting intersection.")
	disconnect_intersections(start_intersection, end_intersection, false)
	connect_intersections(start_intersection, end_intersection, new_road_net_info, false)
	
	if do_update:
		emit_signal("graph_changed")
	return get_connection(start_intersection, end_intersection)

func _generate_id(road_intersection: Vector3):
	var _position: Vector3 = road_intersection
#	_position -= Vector3(-4096, -4096, -4096)
	return int((_position.x + _position.y + _position.z)+4098)

func subdivide_intersections(start_intersection: RoadIntersection, end_intersection: RoadIntersection, road_net_info: RoadNetworkInfo):
	var segment = get_connection(start_intersection, end_intersection)
	if segment.distance > road_net_info.subdivide_length:
		# find position at distance from start
		var t = range_lerp(road_net_info.subdivide_length, 0, segment.distance, 0, 1.0)
		var position = road_net_info.create_intersection(start_intersection.linear_interpolate(end_intersection, t))
		add_intersection(position, false)
		var segments = split_at_postion(segment, position, road_net_info)
		print(segments)
		

#	var visited = [end_intersection]
#	var segment
#	if longest_path:
#		segment = get_longest_known_segment_from(end_intersection, visited)
#	else:
#		segment = get_shortest_known_segment_from(end_intersection, visited)
#	visited.append(segment.start_position)
#	while segment != null:
#		if longest_path:
#			segment = get_longest_known_segment_from(segment.start_position, visited)
##			print(segment)
#		else:
#			segment = get_shortest_known_segment_from(segment.start_position, visited)
#		if segment:
#			visited.append(segment.start_position)
##			print(visited)
#			if segment.start_position == start_intersection:
#				print("found")
#				break
#
#	visited.invert()
#	return visited

func has_intersection(intersection):
	return intersection in intersections
	

func draw(line_color = Color.white, circle_color = Color.black):
	if auto_clear_when_draw:
		immediate_geo.clear()
	for intersection in intersections:
		DrawingUtils.draw_empty_circle(immediate_geo, intersection.position, 0.5, circle_color)
	
	immediate_geo.begin(Mesh.PRIMITIVE_LINES)
	for connection in network.values():
		DrawingUtils.draw_line(immediate_geo, connection.start_position.position, connection.end_position.position, line_color)
	immediate_geo.end()

func get_closest_node(to_position: Vector3, distance: float = 0.5):
	var snapped: RoadIntersection
	var aabb = _get_aabb_for_query(to_position)
	var query = quad_tree.query(aabb)
	for object in query:
		if to_position.distance_to(object.translation) < distance and object.has_meta("_intersection"):
			if object.get_meta("_intersection").visible:
				snapped = object.get_meta("_intersection")
	return snapped

func get_closest_segment(to_position: Vector3, distance: float = 1.5) -> RoadSegment:
	var snapped_segment: RoadSegment
	var aabb = _get_aabb_for_query(to_position)
	var query = quad_tree_edge.query(aabb)
	for object in query:
		if object.has_meta("_connection") and object.get_meta("_connection").distance_to(to_position) < distance:
			if object.get_meta("_connection").visible:
				snapped_segment = object.get_meta("_connection")
	return snapped_segment

func get_closest_bezier_segment(to_position: Vector3, distance: float = 1.5) -> RoadBezier:
	var snapped_bezier: RoadBezier
	var aabb = _get_aabb_for_query(to_position)
	var query = quad_tree_edge_bezier.query(aabb)
	for object in query:
		if object.has_meta("_connection") and object.get_meta("_connection").distance_to(to_position) < distance:
			if object.get_meta("_connection").visible:
				snapped_bezier = object.get_meta("_connection")
	return snapped_bezier
	
func get_connection(start_intersection: RoadIntersection, end_intersection: RoadIntersection) -> RoadSegment:
	if are_intersections_connected(start_intersection, end_intersection):
		return network[[start_intersection, end_intersection]]
	return null

func _set_connection(start_intersection: RoadIntersection, end_intersection: RoadIntersection, connection: RoadSegment):
	network[[start_intersection, end_intersection]] = connection

func get_connection_with_bezier(start_intersection: RoadIntersection, middle_intersection: RoadIntersection, end_intersection: RoadIntersection) -> RoadBezier:
	if are_intersections_connected_with_bezier(start_intersection, middle_intersection, end_intersection):
		return network[[start_intersection, middle_intersection, end_intersection]]
	return null

func _set_connection_with_bezier(start_intersection: RoadIntersection, middle_intersection: RoadIntersection, end_intersection: RoadIntersection, connection: RoadBezier):
	network[[start_intersection, middle_intersection, end_intersection]] = connection

func clear(do_update: bool = true):
	if use_astar:
		quad_tree.clear()
	if use_astar:
		astar.clear()
	network.clear()
	intersections.clear()
	if do_update:
		emit_signal("graph_changed")

func delete_connection(connection: RoadSegment, clear_orphans: bool = true, do_update: bool = true):
	disconnect_intersections(connection.start_position, connection.end_position, false)
	if clear_orphans:
		if connection.start_position.connections.size() < 1:
			remove_intersection(connection.start_position, false, false)
		if connection.end_position.connections.size() < 1:
			remove_intersection(connection.end_position, false, false)
	if do_update:
		emit_signal("graph_changed")

func delete_connection_with_bezier(connection: RoadBezier, clear_orphans: bool = true, do_update: bool = true):
	disconnect_intersections_with_bezier(connection.start_position, connection.middle_position, connection.end_position, false)
	if clear_orphans:
		if connection.start_position.connections.size() < 1:
			remove_intersection(connection.start_position, false, false)
		if connection.middle_position.connections.size() < 1:
			remove_intersection(connection.middle_position, false, false)
		if connection.end_position.connections.size() < 1:
			remove_intersection(connection.end_position, false, false)
	if do_update:
		emit_signal("graph_changed")
	

func _get_aabb_for_query(position: Vector3, radius: int = 10, height: int = 20) -> AABB:
	var mesh_inst = MeshInstance.new()
	var cylinder = CylinderMesh.new()
	cylinder.top_radius = radius
	cylinder.bottom_radius = radius
	cylinder.height = height
	mesh_inst.mesh = cylinder
	var aabb = mesh_inst.get_aabb()
	aabb.position.x += position.x
	aabb.position.y += position.y
	aabb.position.z += position.z
	mesh_inst.queue_free()
	return aabb

#func _ready():
#	var intersect_1 = RoadIntersection.new(Vector3(2, 0, 3), [])
#	var intersect_2 = RoadIntersection.new(Vector3(6, 0, 5.3), [])
#	var intersect_3 = RoadIntersection.new(Vector3(5, 0, 3), [])
#	var intersect_4 = RoadIntersection.new(Vector3(3, 0, 8), [])
#	var intersect_5 = RoadIntersection.new(Vector3(6, 0, 8), [])
#	var intersect_6 = RoadIntersection.new(Vector3(3.3, 0, 5), [])
#
#	add_intersection(intersect_1)
#	add_intersection(intersect_2)
#	add_intersection(intersect_3)
#	add_intersection(intersect_4)
#	add_intersection(intersect_5)
#	add_intersection(intersect_6)
#
#	connect_intersections(intersect_1, intersect_2)
#	connect_intersections(intersect_2, intersect_3)
#	connect_intersections(intersect_1, intersect_4)
#	connect_intersections(intersect_3, intersect_5)
#	connect_intersections(intersect_4, intersect_5)
#	connect_intersections(intersect_5, intersect_6)
#	connect_intersections(intersect_3, intersect_6)
#
#	var shortest_path = find_path(intersect_1, intersect_6, true)
#
#	draw($ImmediateGeometry)
#
#	$ImmediateGeometry.begin(Mesh.PRIMITIVE_LINES)
#	var previous_point = null
#	for point in shortest_path:
#		if previous_point == null:
#			previous_point = point
#			continue
#		draw_line($ImmediateGeometry, previous_point.position, point.position, Color.red)
#		previous_point = point
#	$ImmediateGeometry.end()

func _create_quad_tree_node(intersection):
	var spatial = Spatial.new()
	spatial.translation = intersection.position
	spatial.set_meta("_intersection", intersection)
	spatial.set_meta("_aabb", _get_spatial_aabb(intersection.position))
	return spatial

func _create_quad_tree_edge(connection):
	var spatial = Spatial.new()
	spatial.set_meta("_connection", connection)
	spatial.set_meta("_aabb", connection.get_bounds())
	return spatial

func _get_spatial_aabb(intersection: Vector3):
	return AABB(
		(Vector3.ONE * -0.25)+intersection, 
		Vector3.ONE * 0.5
	)

