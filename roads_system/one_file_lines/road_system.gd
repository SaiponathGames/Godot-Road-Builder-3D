extends Spatial
class_name RoadNetworkOneLine


enum Direction {FORWARD, BACKWARD}

class GraphTest extends Resource:
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

class GraphTestNode extends Spatial:
	var graph: GraphTest

	func _ready():
		graph = GraphTest.new()

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


class RoadLane:
	var lane_info: RoadLaneInfo
	var segment: RoadSegmentLinear
	
	var start_point: RoadIntersection
	var end_point: RoadIntersection
	
	var road_network
	
	func _init(_lane_info: RoadLaneInfo, _segment: RoadSegmentLinear):
		self.segment = _segment
		self.start_point = _segment.start_position
		self.end_point = _segment.end_position
		self.road_network = _segment.road_network
		self.lane_info = _lane_info
	
class RoadLaneInfo extends Resource:
	export var direction: int = Direction.FORWARD
	export var width: float
	export var offset: float
	
	func _init(_direction, _width, _offset):
		self.direction = _direction
		self.width = _width
		self.offset = _offset
	
	func instance(_segment: RoadSegmentLinear):
		return RoadLane.new(self, _segment)
		

class RoadLaneIntersection:
	var out_lanes: Array = [] # Array[RoadLane]
	var in_lanes = [] # Array[RoadLane]
	
class RoadIntersectionTest:
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

class RoadNetworkInfoTest extends Reference:
	export var name: String
	export var id: String
	export var lanes = [] # Array[RoadLaneInfo]
	export var length: float = 1
	export var width: float = 0.5
	export var end_radius: float = 0.5
	export var curvature: float = 0.3
	export var subdivide_length = 5.0

	func _init(_id: String, _name: String, _length: float, _width: float, _end_radius: float, _curvature: float = 0.3, _lanes = [], _subdivide_length = 5):
		self.id = _id
		self.name = _name
		self.length = _length
		self.width = _width
		self.end_radius = _end_radius
		self.curvature = _curvature
		self.subdivide_length = _subdivide_length
		self.lanes = _lanes

	func create_intersection(position: Vector3) -> RoadIntersection:
		return RoadIntersection.new(position, self)


class RoadSegmentBaseTest extends Reference:

	var start_position: RoadIntersection
	var end_position: RoadIntersection

	var length: float

	var road_network
	var road_network_info: RoadNetworkInfo

	var lanes = [] # Array[RoadLanes]

	enum {FORWARD = 1, BACKWARD = 2, BIDIRECTIONAL = 3}
	var direction = FORWARD

	var visible = true

	func _init(_start_position: RoadIntersection, _end_position: RoadIntersection, _road_network_info: RoadNetworkInfo, _direction = BIDIRECTIONAL):
		self.start_position = _start_position
		self.end_position = _end_position
		self.road_network_info = _road_network_info
		self.length = get_length()
		self.direction = _direction
		instance_lanes()

	# Abstract methods (do not delete)

	func get_length():
		pass

	# warning-ignore:unused_argument
	func get_point(t):
		pass

	# warning-ignore:unused_argument
	func project_point(position: Vector3):
		pass

	func get_aabb():
		pass

	# End of abstract methods
		
	func instance_lanes():
		for lane in self.road_network_info.lanes:
			lanes.append(lane.instance(self))

	func set_owner(road_net):
		self.road_network = road_net

	func get_points(spacing, resolution):
		var points = [start_position.position]
		var previous_point = start_position.position
		var distance_since_last_point = 0
		var division_amount = length * resolution * 10
		var time = 0
		while time <= 1:
			time += 1/division_amount
			var point = get_point(time)
			distance_since_last_point += point.distance_to(previous_point)
			while distance_since_last_point >= spacing:
				var over_shoot_distance = distance_since_last_point - spacing
				var new_point = point + (previous_point - point).normalized() * over_shoot_distance
				points.append(new_point)
				distance_since_last_point = over_shoot_distance
				previous_point = new_point
			previous_point = point
		return points

	func distance_to(position: Vector3):
		var closest_point = project_point(position)
		return closest_point.distance_to(position)
		
	func distance_squared_to(position: Vector3):
		var closest_point = project_point(position)
		return closest_point.distance_squared_to(position)

	func direction_to(position: Vector3):
		var closest_point = project_point(position)
		return closest_point.direction_to(position)

	func split_at_position(position: RoadIntersection): # Array[RoadSegmentBase]
		pass

	func subdivide(): # Array[RoadSegmentBase]
		pass

	func join_segments(segments: Array): # segments: Array[RoadSegmentBase] -> RoadSegmentBase
		pass
		
class RoadSegmentLinearTest extends RoadSegmentBaseTest:
	
	func _init(_start_position, _end_position, _road_net_info, _direction).(_start_position, _end_position, _road_net_info, _direction):
		pass

	func project_point(to_position: Vector3):
		return Geometry.get_closest_point_to_segment(to_position, start_position.position, end_position.position)

	func get_aabb() -> AABB:
		var aabb: AABB
		if int(start_position.position.x) == int(end_position.position.x):
			if int(start_position.position.z) == int(end_position.position.z):
				return AABB()
			else:
				aabb = AABB(start_position.position + (Vector3(1, 0, 1)), Vector3(1, 0, 1))
				aabb.end = end_position.position - (Vector3(1, 0, 1))
		elif int(start_position.position.z) == int(end_position.position.z):
			aabb =  AABB(start_position.position + (Vector3(1, 0, 1)), Vector3(1, 0, 1))
			aabb.end = end_position.position - (Vector3(1, 0, 1))
		else:
			aabb = AABB(start_position.position, Vector3(1, 0, 1))
			aabb.end = end_position.position
		return aabb

	func get_point(t):
		return start_position.linear_interpolate(end_position, t)

	func get_length():
		return start_position.distance_to(end_position)

	func split_at_position(position) -> Array:
		self.road_network.delete_segment(self)
		var seg_1 = get_script().new(self.start_position, position, road_network_info, direction)
		var seg_2 = get_script().new(position, self.end_position, road_network_info, direction)
		
		seg_1 = self.road_network.create_segment(seg_1)
		seg_2 = self.road_network.create_segment(seg_2)
		
		return [seg_1, seg_2]

class RoadSegmentBezierTest extends RoadSegmentBaseTest:
	var middle_position: RoadIntersection

	var lut = []

	var current_resolution setget set_current_resolution

	func _init(_start_position, _middle_position, _end_position, _road_net_info, _direction).(_start_position, _end_position, _road_net_info, _direction):
		self.middle_position = _middle_position
		calculate_lut()
		
	func set_current_resolution(value):
		current_resolution = value
		calculate_lut(value, false)

	func _quadratic_bezier(p0: Vector3, p1: Vector3, p2: Vector3, t: float):
		var q0 = p0.linear_interpolate(p1, t)
		var q1 = p1.linear_interpolate(p2, t)
		return q0.linear_interpolate(q1, t)

	func get_length(resolution = 16):
		if current_resolution != resolution:
			calculate_lut(resolution, false)
		var sum = 0
		var previous_point = start_position.position
		for point_t in lut:
			var point = point_t[0]
			sum += previous_point.distance_to(point)
			previous_point = point
		return sum

	func get_point(t) -> Vector3:
		return _quadratic_bezier(start_position.position, middle_position.position, end_position.position, t)

	func get_aabb():
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
		
		return _refine_binary(position, i, send_time)

	func _refine_binary(point: Vector3, index: int, send_time = false,  max_iters = 25, span = 0.001):
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
				var new_point = _quadratic_bezier(start_position.position, middle_position.position, end_position.position, test_t)
				var point_dist = point.distance_to(new_point)
				if point_dist < dist:
					dist = point_dist
					point_on_curve = new_point
					return_t = test_t
					index = j
				lut_out.append([new_point, t1 + j * step])
			lut_out.append(_lut[i2])
			
			_lut = lut_out.duplicate()
			count += 1
		if send_time:
			return [point_on_curve, return_t]
		return point_on_curve


	func calculate_lut(resolution = 20, change_resolution = true) -> void:
		var t = 0
		while t <= 0.9:
			t += 1/float(resolution)
			t = clamp(t, 0, 1)
			var position = _quadratic_bezier(start_position.position, middle_position.position, end_position.position, t)
			lut.append([position, t])
		if change_resolution:
			current_resolution = resolution

	func hull(t):
		var list = []
		var positions = [start_position.position, middle_position.position, end_position.position]
	#	var test_p = []
		list.append_array(positions)
		while positions.size() > 1:
			var _p = []
			for i in range(positions.size()-1):
				var pt = lerp(positions[i], positions[i+1], t)
				list.append(pt)
				_p.push_back(pt)
			positions = _p.duplicate()
		return list
		


export(NodePath) var graph_node
export(NodePath) var quad_tree_node
export(bool) var use_astar

## Minimum vector to calculate id from.
export var min_vector = Vector3(-1024, -1024, -1024)

var graph: GraphResourceNode
var quad_tree: QuadTreeNode
var astar = AStar.new()

func _ready():
	if graph_node:
		graph = get_node(graph_node)
	if quad_tree_node:
		quad_tree = get_node(quad_tree_node)

var graph_road_map = {}
var graph_seg_map = {}

func create_segment(segment: RoadSegmentBase) -> RoadSegmentBase: 
	var from = segment.start_position
	var to =  segment.end_position
	
	var from_id = _get_id(from.position, min_vector)
	var to_id = _get_id(to.position, min_vector)

	if not graph.has_point(from_id):
		_add_road_intersection(from_id, from)
		
	if not graph.has_point(to_id):
		_add_road_intersection(to_id, to)
		
	var seg_id = graph.connect_points(from_id, to_id, null, true).get("seg_id")
	if seg_id:
		if quad_tree:
			var qt_segment = _make_quad_tree_object(segment)
			quad_tree.add_body(qt_segment)
			segment.set_meta("_qt_segment", qt_segment)
		if use_astar:
			astar.connect_points(from_id, to_id)
		from.connections.append(segment)
		to.connections.append(segment)
		
		graph_seg_map[seg_id] = segment
	
		return segment
	return null

func delete_segment(segment: RoadSegmentBase): 
	var from = segment.start_position
	var to =  segment.end_position
	
	var from_id = _get_id(from.position, min_vector)
	var to_id = _get_id(to.position, min_vector)
	
	var seg_id = graph.get_segment(from_id, to_id).get("seg_id")
	if seg_id:
		graph.disconnect_points(from_id, to_id)
		if use_astar:
			astar.disconnect_points(from_id, to_id)
		
		from.connections.erase(segment)
		to.connections.erase(segment)
		if quad_tree:
			var qt_node = segment.get_meta("_qt_segment")
			quad_tree.remove_body(qt_node)
			segment.get_meta('_qt_segment').queue_free()
			segment.remove_meta("_qt_segment")
		
		graph_seg_map.erase(seg_id)
		
		if from.connections.empty() and graph.has_point(from_id):
			_remove_road_intersection(from_id)
		
		if to.connections.empty() and graph.has_point(to_id):
			_remove_road_intersection(to_id)
			
		
func get_segment(from: RoadIntersection, to: RoadIntersection) -> RoadSegmentBase:
	var from_id = _get_id(from.position, min_vector)
	var to_id = _get_id(to.position, min_vector)
	
	var seg_id = graph.get_segment(from_id, to_id).get("seg_id")
	if seg_id:
		return graph_seg_map[seg_id] as RoadSegmentBase
	return null
	
func upgrade_segment(segment: RoadSegmentBase, road_net_info: RoadNetworkInfo): 
	segment.road_network_info = road_net_info

func get_closest_segment_to(position: Vector3, distance: float = 0.5) -> RoadSegmentBase:
	var closest_intersection: RoadSegmentBase
	var closest_dist = INF
	var aabb = _get_aabb_to_test(position)
	var query = quad_tree.query(aabb)
	for object in query:
		if object.has_meta("_segment"): 
			var dist = object.get_meta("_segment").distance_to(position)
			if dist < distance and dist < closest_dist:
				if object.get_meta("_segment").visible:
					closest_intersection = object.get_meta("_segment") as RoadSegmentBase
					closest_dist = dist
	return closest_intersection

func get_closest_point_to(position: Vector3, distance: float = 0.5) -> RoadIntersection:
	var closest_intersection: RoadIntersection
	var closest_dist = INF
	var aabb = _get_aabb_to_test(position)
#	aabb = aabb.abs()
	var query = quad_tree.query(aabb)
	for object in query:
		if object.has_meta("_intersection"): 
			var dist = object.get_meta("_intersection").position.distance_to(position)
			if dist < distance and dist < closest_dist:
				if object.get_meta("_intersection").visible:
					closest_intersection = object.get_meta("_intersection") as RoadIntersection
					closest_dist = dist
	return closest_intersection

func subdivide_segment(segment: RoadSegmentBase):
	return segment.subdivide()

func split_segment_at(position: RoadIntersection, segment: RoadSegmentBase):
	return segment.split_at_position(position)

func join_segments(segment: RoadSegmentBase, segments: Array): # segments: Array[RoadSegmentBase] -> RoadSegmentBase
	return segment.join_segments(segments)

# ref https://gdalgorithms-list.narkive.com/s2wbl3Cd/axis-aligned-bounding-box-of-cylinder
func _get_aabb_to_test(position, radius = 1, height = 2):
	var a = position
	var b = a + Vector3.UP * height
	var tmp = Vector3.ONE * radius # Vector3(radius, radius, radius)
	var aabb = AABB(min_vec(a, b) - tmp, max_vec(a, b) + tmp)
	return aabb

func min_vec(a, b):
	return Vector3(min(a.x, b.x), min(a.y, b.y), min(a.z, b.z))

func max_vec(a, b):
	return Vector3(max(a.x, b.x), max(a.y, b.y), max(a.z, b.z))

func _get_id(_position: Vector3, _min_vec: Vector3):
	var p_min = (_min_vec.x + _min_vec.y + _min_vec.z)
	return int((_position.x + + _position.z * -(p_min) + _position.y * -(p_min*p_min) - pow(p_min, 3)))

func _make_quad_tree_object(road_object = null) -> Spatial:
	var spatial = Spatial.new()
	if road_object is RoadIntersection:
		spatial.name = "Node"
		spatial.set_meta("_intersection", road_object)
	elif road_object is RoadSegmentBase:
		spatial.name = "Edge"
		spatial.set_meta("_segment", road_object)
	spatial.set_meta("_aabb", road_object.get_aabb())
	return spatial

func _add_road_intersection(id: int, intersection: RoadIntersection) -> void:
	graph.add_point(id, intersection.position)
	graph_road_map[id] = intersection
	if use_astar:
		astar.add_point(id, intersection.position)
	intersection.set_owner(self)
	if quad_tree:
		var qt_node = _make_quad_tree_object(intersection)
		intersection.set_meta('_qt_node', qt_node)
		quad_tree.add_body(qt_node)

func _remove_road_intersection(id: int):
	var intersection: RoadIntersection = graph_road_map[id]
	graph.remove_point(id)
	if use_astar:
		astar.remove_point(id)
	intersection.set_owner(null)
	graph_road_map.erase(id)
	if quad_tree:
		var qt_node = intersection.get_meta('_qt_node')
		quad_tree.remove_body(qt_node)
		intersection.get_meta('_qt_node').queue_free()
		intersection.remove_meta("_qt_node")
