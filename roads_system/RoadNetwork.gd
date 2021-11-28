extends Node
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

func create_segment(from: RoadIntersection, to: RoadIntersection, road_net_info: RoadNetworkInfo) -> RoadSegmentBase: 
	var from_id = _get_id(from.position, min_vector)
	var to_id = _get_id(to.position, min_vector)
	if not graph.has_point(from_id):
		graph.add_point(from_id, from.position)
		graph_road_map[from_id] = from
		astar.add_point(from_id, from.position)
		var qt_node = _make_quad_tree_object(from)
		from.set_meta('_qt_node', qt_node)
		
	if not graph.has_point(to_id):
		graph.add_point(to_id, to.position)
		graph_road_map[to_id] = to
		astar.add_point(to_id, to.position)
		
	var seg_id = graph.connect_points(from_id, to_id, null, true).get("seg_id")
	if seg_id:
		var seg = RoadSegmentLinear.new(from, to, road_net_info, RoadSegmentBase.BIDIRECTIONAL)
		
		astar.connect_points(from_id, to_id)
		from.connections.append(seg)
		to.connections.append(seg)
		
		graph_seg_map[seg_id] = seg
	
		return seg
	return null

func delete_segment(segment: RoadSegmentBase): 
	var from = segment.start_position
	var to =  segment.end_position
	
	var from_id = _get_id(from.position, min_vector)
	var to_id = _get_id(to.position, min_vector)
	
	var seg_id = graph.get_segment(from_id, to_id).get("seg_id")
	if seg_id:
		graph.disconnect_points(from_id, to_id)
		astar.disconnect_points(from_id, to_id)
		
		from.connections.erase(segment)
		to.connections.erase(segment)
		
		graph_seg_map.erase(seg_id)
		
		if from.connections.empty() and graph.has_point(from_id):
			graph.remove_point(from_id)
			astar.remove_point(from_id)
		if to.connections.empty() and graph.has_point(from_id):
			graph.remove_point(to_id)
			astar.remove_point(to_id)
		
func get_segment(from: RoadIntersection, to: RoadIntersection) -> RoadSegmentBase:
	var from_id = _get_id(from.position, min_vector)
	var to_id = _get_id(to.position, min_vector)
	
	var seg_id = graph.get_segment(from_id, to_id).get("seg_id")
	if seg_id:
		return graph_seg_map[seg_id] as RoadSegmentBase
	return null
	
func upgrade_segment(segment: RoadSegmentBase, road_net_info: RoadNetworkInfo): 
	segment.road_network_info = road_net_info

func get_closest_segment(): # -> RoadSegmentBase:
	pass

func get_closest_point(): # -> RoadIntersection:
	pass

func subdivide_segment(segment: RoadSegmentBase):
	pass

func split_segment_at(position: RoadIntersection, segment: RoadSegmentBase):
	pass

func join_segments(segments: Array): # segments: Array[RoadSegmentBase] -> RoadSegmentBase
	pass

func _get_id(_position: Vector3, _min_vec: Vector3):
	var p_min = (_min_vec.x + _min_vec.y + _min_vec.z)
	return int((_position.x + _position.y * -(p_min) + _position.z * -(p_min*p_min) - pow(p_min, 3)))

func _make_quad_tree_object(intersection: RoadIntersection = null, segment: RoadSegmentBase = null) -> Spatial:
	var spatial = Spatial.new()
	if intersection:
		spatial.name = "Node"
		spatial.set_meta("_intersection", intersection)
		spatial.set_meta("_aabb", intersection.get_aabb())
	elif segment:
		spatial.name = "Edge"
		spatial.set_meta("_segment", segment)
		spatial.set_meta("_aabb", segment.get_aabb())
	return spatial
