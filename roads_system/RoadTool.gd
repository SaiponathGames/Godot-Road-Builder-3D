extends Spatial

export(NodePath) var world_road_network_node
onready var world_road_network: RoadNetwork = get_node(world_road_network_node) as RoadNetwork

const RoadIntersection = RoadNetwork.RoadIntersection
const RoadSegment = RoadNetwork.RoadSegment

var _snapped: RoadIntersection
var _snapped_segment: RoadSegment

var _start_segment: RoadSegment
var _end_segment: RoadSegment

var _drag_start: RoadIntersection
var _drag_current: RoadIntersection
var _drag_end: RoadIntersection

var _is_dragging = false

var continue_dragging = true

var disable_tool

func _input(event):
	if event is InputEventKey:
		if event.scancode == KEY_T:
			disable_tool = true
		if event.scancode == KEY_Y:
			disable_tool = false

	if disable_tool:
		return

	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			if !_is_dragging: # start a new road
				if _snapped:
					_drag_start = create_new_intersection(_snapped.position)
					$RoadNetwork.add_intersection(_drag_start)
				elif _snapped_segment:
					_start_segment = _snapped_segment
					_drag_start = create_new_intersection(_cast_ray_to(event.position))
					$RoadNetwork.add_intersection(_drag_start)
				else:
					var new_intersection = create_new_intersection(_cast_ray_to(event.position))
					_drag_start = new_intersection
					$RoadNetwork.add_intersection(_drag_start)
				_is_dragging = true
				_snapped = null
				_snapped_segment = null

			elif _is_dragging: # end the dragging, and create new road in world
				if _snapped:
					_drag_end = create_new_intersection(_snapped.position)
					$RoadNetwork.add_intersection(_drag_end)
				elif _snapped_segment:
					_end_segment = _snapped_segment
					_drag_end = create_new_intersection(_cast_ray_to(event.position))
					$RoadNetwork.add_intersection(_drag_end)
				else:
					var new_intersection = create_new_intersection(_cast_ray_to(event.position))
					_drag_end = new_intersection
					$RoadNetwork.add_intersection(_drag_end)
					$RoadNetwork.connect_intersections(_drag_start, _drag_end)
				
				var _split = false
				var start_intersection = world_road_network.get_closest_node(_drag_start.position)
				var end_intersection = world_road_network.get_closest_node(_drag_end.position)
				if !start_intersection:
					start_intersection = create_new_intersection(_drag_start.position)
				if !end_intersection:
					end_intersection = create_new_intersection(_drag_end.position)
				
				# add to world
				if !world_road_network.has_intersection(start_intersection):
					world_road_network.add_intersection(start_intersection)
				if !world_road_network.has_intersection(end_intersection):
					world_road_network.add_intersection(end_intersection)
				
				print(_start_segment, _end_segment)
				if _start_segment:
					world_road_network.split_at_postion(_start_segment, start_intersection)
					_split = true
				if _end_segment:
					world_road_network.split_at_postion(_end_segment, end_intersection)
					_split = true
				
				if start_intersection.position != end_intersection.position:
					world_road_network.connect_intersections(start_intersection, end_intersection)
				
#				world_road_network.draw()
				$RoadNetwork.clear()
				_is_dragging = continue_dragging
				if continue_dragging:
					print(start_intersection, end_intersection)
					_drag_start = create_new_intersection(_drag_end.position)
					$RoadNetwork.add_intersection(_drag_start)
				_drag_current = null
				_snapped_segment = null
				_start_segment = null
				_end_segment = null
				_drag_end = null
				_snapped = null
				if !continue_dragging:
					_drag_start = null

		if event.button_index == BUTTON_RIGHT and event.pressed:
			if _is_dragging:
				_drag_current = null
				_drag_start = null
				_drag_end = null
				_start_segment = null
				_end_segment = null
				_snapped_segment = null
				_is_dragging = false
				_snapped = null
				$RoadNetwork.clear()

	if event is InputEventMouseMotion:
		_snapped = null
		if _drag_current:
			$RoadNetwork.remove_intersection(_drag_current)
			_drag_current = null
	
		var new_intersection = create_new_intersection(_cast_ray_to(event.position))
		_drag_current = new_intersection
		$RoadNetwork.add_intersection(_drag_current)
		if _is_dragging:
			$RoadNetwork.connect_intersections(_drag_start, _drag_current)
		_snapped_segment = null
		_snapped = null
		
		for segment in world_road_network.network.values():
			# find distance to the segment
			var dist = _distance_to_segment(segment.start_position.position, segment.end_position.position, _drag_current.position)
			print(dist)
			var closest_point = Geometry.get_closest_point_to_segment(segment.start_position.position, segment.end_position.position, _drag_current.position)
			if abs(dist) < 1:
				if !_is_dragging:
					prints(_drag_current.position == closest_point, dist < 1)
					_drag_current.position = closest_point
					_snapped_segment = segment
					prints(_drag_start, _drag_end, _drag_current, _start_segment, _end_segment, _snapped_segment, closest_point, dist)
				elif _is_dragging and is_instance_valid(_drag_start) and is_instance_valid(_drag_current) and _drag_start.position != closest_point:
					_drag_current.position = closest_point
					_snapped_segment = segment
		
		var closest_node = world_road_network.get_closest_node(new_intersection.position)
		if closest_node:
			_snapped = closest_node
			_drag_current.position = _snapped.position
			print("working?")
		
		$RoadNetwork.draw()
		$RoadNetwork/MeshInstance.update()

func _distance_to_segment(start_point: Vector3, end_point: Vector3, point: Vector3):
	var d = end_point - start_point
	if d.length() == 0:
		return point.distance_to(start_point)

	var v = point - start_point

	var t = clamp(d.dot(v)/d.dot(d), 0.0, 1.0)
	var projection = start_point + t * d
	return point.distance_to(projection)

func _set_snapped(new_intersection: RoadIntersection):
	_snapped = world_road_network.get_closest_node(new_intersection.position)
	if _drag_start and _snapped and _snapped.position == _drag_start.position:
		return
	if _snapped and _drag_current:
		_drag_current.position = _snapped.position

func _cast_ray_to(postion: Vector2):
	var camera = get_viewport().get_camera()
	var from = camera.project_ray_origin(postion)
	var to = from + camera.project_ray_normal(postion) * camera.far
	return get_world().direct_space_state.intersect_ray(from, to).get("position", Vector3(NAN, NAN, NAN))

func create_new_intersection(position) -> RoadIntersection:
	return RoadIntersection.new(position)

