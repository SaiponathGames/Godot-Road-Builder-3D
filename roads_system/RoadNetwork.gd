extends Spatial
class_name RoadNetwork

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

func get_closest_segment_to(position, distance: float = 0.5) -> RoadSegmentBase:
	var closest_intersectioon: RoadSegmentBase
	var aabb = _get_aabb_to_test(position)
	var query = quad_tree.query(aabb)
	for object in query:
		if object.has_meta("_segment") and object.get_meta("_segment").distance_to(position) < distance:
			if object.get_meta("_segment").visible:
				closest_intersectioon = object.get_meta("_segment") as RoadSegmentBase
	return closest_intersectioon

func get_closest_point_to(position: Vector3, distance: float = 0.5) -> RoadIntersection:
	var closest_intersectioon: RoadIntersection
	var aabb = _get_aabb_to_test(position, distance)
	var query = quad_tree.query(aabb)
	for object in query:
		if object.has_meta("_intersection") and object.get_meta("_intersection").position.distance_to(position) < distance:
			if object.get_meta("_intersection").visible:
				closest_intersectioon = object.get_meta("_intersection") as RoadIntersection
	return closest_intersectioon

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
	intersection.road_network = self
	if quad_tree:
		var qt_node = _make_quad_tree_object(intersection)
		intersection.set_meta('_qt_node', qt_node)
		quad_tree.add_body(qt_node)

func _remove_road_intersection(id: int):
	var intersection = graph_road_map[id]
	graph.remove_point(id)
	if use_astar:
		astar.remove_point(id)
	intersection.road_network = null
	graph_road_map.erase(id)
	if quad_tree:
		var qt_node = intersection.get_meta('_qt_node')
		quad_tree.remove_body(qt_node)
		intersection.get_meta('_qt_node').queue_free()
		intersection.remove_meta("_qt_node")
