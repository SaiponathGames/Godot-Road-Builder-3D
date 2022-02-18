extends Spatial
class_name RoadNetwork

signal graph_changed(road_net)

export(NodePath) var graph_node
export(NodePath) var quad_tree_node
export(bool) var use_astar

## Minimum vector to calculate id from.
export var min_vector = Vector3(-128, -64, -128)

var graph: GraphResourceNode
var quad_tree: QuadTreeNode
var astar = AStar.new()

func _ready():
	if graph_node:
		graph = get_node(graph_node)
	if quad_tree_node:
		quad_tree = get_node(quad_tree_node)

## For graph intersections
var graph_inter_map = {}
## For graph segments
var graph_seg_map = {}


func create_segment(segment: RoadSegmentBase) -> RoadSegmentBase: 
	var from = segment.start_position.intersection
	var to = segment.end_position.intersection
	
	var from_id = from.get_id(min_vector)
	var to_id = to.get_id(min_vector)

	if not graph.has_point(from_id):
		_add_road_intersection(from_id, from)
		
	if not graph.has_point(to_id):
		_add_road_intersection(to_id, to)
	
	var seg_id = segment.get_id(min_vector)
	seg_id = graph.connect_points(from_id, to_id, seg_id, true).get("seg_id")
	if seg_id:
		if quad_tree:
			var qt_segment = _make_quad_tree_object(segment)
			quad_tree.add_body(qt_segment)
			segment.set_meta("_qt_segment", qt_segment)
		if use_astar:
			astar.connect_points(from_id, to_id)
		
		graph_seg_map[seg_id] = segment
		emit_signal("graph_changed", self)
		return segment
	return null


func delete_segment(segment: RoadSegmentBase): 
	var from = segment.start_position.intersection
	var to = segment.end_position.intersection
	
	var from_id = from.get_id(min_vector)
	var to_id = to.get_id(min_vector)
	
	var seg_id = segment.get_id(min_vector)
	seg_id = graph.get_segment(from_id, to_id, seg_id).get("seg_id")
	if seg_id:
		graph.disconnect_points(from_id, to_id, seg_id)
		if use_astar:
			astar.disconnect_points(from_id, to_id)
		
		from.connections.erase(segment)
		to.connections.erase(segment)
		if quad_tree:
			var qt_node = segment.get_meta("_qt_segment")
			quad_tree.remove_body(qt_node)
			segment.remove_meta("_qt_segment")
			qt_node.queue_free()
		
		graph_seg_map.erase(seg_id)
		segment.delete()
		if from.connections.empty() and graph.has_point(from_id):
			_remove_road_intersection(from_id)
		
		if to.connections.empty() and graph.has_point(to_id):
			_remove_road_intersection(to_id)
	emit_signal("graph_changed", self)

func get_all_segments_from_to(from: RoadIntersection, to: RoadIntersection) -> Array:
	var from_id = from.get_id(min_vector)
	var to_id = to.get_id(min_vector)
	
	var segments = []
	var segment_dicts = graph.get_all_segments_from_to(from_id, to_id)
	for segment_dict in segment_dicts:
		var seg_id = segment_dict.get("seg_id")
		if seg_id:
			segments.append(graph_seg_map[seg_id])
	return segments


func get_all_segmentas_from_to_of_net_info(from: RoadIntersection, to: RoadIntersection, net_info: RoadNetworkInfo):
	var segments_got = get_all_segments_from_to(from, to)
	var segments = []
	for segment in segments_got:
		if segment.road_network_info == net_info:
			segments.append(segment)
	return segments


func get_all_segments_from_to_of_type(from: RoadIntersection, to: RoadIntersection, type = RoadSegmentBase):
	var segments_got = get_all_segments_from_to(from, to)
	var segments = []
	for segment in segments_got:
		if segment is type:
			segments.append(segment)
	return segments


func get_all_segments() -> Array:
	var segment_dicts = graph.get_all_segments()
	var segments = []
	for segment_dict in segment_dicts:
		var seg_id = segment_dict.get("seg_id")
		if seg_id:
			segments.append(graph_seg_map[seg_id])
	return segments


func get_all_segments_of_type(type = RoadSegmentBase) -> Array:
	var segments_got = get_all_segments()
	var segments = []
	for segment in segments_got:
		if segment is type:
			segments.append(segment)
	return segments


func get_all_segment_of_net_info(net_info: RoadNetworkInfo):
	var segments_got = get_all_segments()
	var segments = []
	for segment in segments_got:
		if segment.road_network_info == net_info:
			segments.append(segment)
	return segments

func get_all_intersections():
	var intersection_dicts =  graph.get_all_intersections()
	var intersections = []
	for intersection_dict in intersection_dicts:
		var inter_id = intersection_dict.get("id")
		if inter_id:
			intersections.append(graph_inter_map[inter_id])
	return intersections
	

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


func min_vec(a, b):
	return Vector3(min(a.x, b.x), min(a.y, b.y), min(a.z, b.z))

func max_vec(a, b):
	return Vector3(max(a.x, b.x), max(a.y, b.y), max(a.z, b.z))

# ref https://gdalgorithms-list.narkive.com/s2wbl3Cd/axis-aligned-bounding-box-of-cylinder
func _get_aabb_to_test(position, radius = 1, height = 2):
	var a = position
	var b = a + Vector3.UP * height
	var tmp = Vector3.ONE * radius # Vector3(radius, radius, radius)
	var aabb = AABB(min_vec(a, b) - tmp, max_vec(a, b) + tmp)
	return aabb

func _make_quad_tree_object(road_object = null) -> Spatial:
	var spatial = Spatial.new()
	if road_object is RoadIntersection:
		spatial.name = "QuadTree - Node"
		spatial.set_meta("_intersection", road_object)
	elif road_object is RoadSegmentBase:
		spatial.name = "QuadTree - Edge"
		spatial.set_meta("_segment", road_object)
	spatial.set_meta("_aabb", road_object.get_aabb())
	return spatial


func _add_road_intersection(id: int, intersection: RoadIntersection) -> void:
# warning-ignore:return_value_discarded
	graph.add_point(id, intersection.position)
	graph_inter_map[id] = intersection
	if use_astar:
		astar.add_point(id, intersection.position)
	intersection.set_owner(self)
	if quad_tree:
		var qt_node = _make_quad_tree_object(intersection)
		qt_node = quad_tree.add_body(qt_node)
		intersection.set_meta('_qt_node', qt_node)


func _remove_road_intersection(id: int):
	var intersection: RoadIntersection = graph_inter_map[id]
	graph.remove_point(id)
	if use_astar:
		astar.remove_point(id)
	intersection.set_owner(null)
	print_debug(graph_inter_map.erase(id))
	if quad_tree:
		var qt_node = intersection.get_meta('_qt_node')
		if is_instance_valid(qt_node):
			quad_tree.remove_body(qt_node)
			intersection.remove_meta("_qt_node")
			qt_node.queue_free()
#	intersection.call_deferred('free') #FIXME: RoadIntersectionNode doesn't delete itself properly causing a crash.


func _on_Graph_graph_changed():
	pass
