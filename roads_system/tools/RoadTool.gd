extends Spatial

export(NodePath) var world_road_network_node
onready var world_road_network: RoadNetwork = get_node(world_road_network_node) as RoadNetwork


export(SpatialMaterial) var buildable_mat
export(SpatialMaterial) var non_buildable_mat

#const RoadLaneInfo = RoadNetwork.RoadLaneInfo

var _snapped: RoadIntersection
var _snapped_segment

var _start_segment
var _end_segment

var _drag_start: RoadIntersection
var _drag_middle: RoadIntersection
var _drag_current: RoadIntersection
var _drag_end: RoadIntersection

var is_curve_tool_on: bool = false
var _is_dragging = false

var continue_dragging = true

var current_info: RoadNetworkInfo

var enabled = true

var buildable = false

func _input(event):
	if event is InputEventKey:
		if event.scancode == KEY_P and event.pressed and !enabled:
			enabled = true
			show()
#			print(enabled)
		elif event.scancode == KEY_P and event.pressed and enabled:
			enabled = false
			hide()
			reset()
			$RoadNetwork.clear()
		
	if !enabled:
		return

	if event is InputEventKey:
		if event.scancode == KEY_V:
			is_curve_tool_on = true
		if event.scancode == KEY_B:
			is_curve_tool_on = false
		
		if event.scancode == KEY_1:
			current_info = RoadNetworkInfo.new("test_id_1", "Test Road 1", 0.5, 1, 1, 0.01, [])
			# RoadLaneInfo.new(RoadNetwork.Direction.FORWARD, 0.5, 0.25), RoadLaneInfo.new(RoadNetwork.Direction.BACKWARD, 0.5, -0.25)
		if event.scancode == KEY_2:
			current_info = RoadNetworkInfo.new("test_id_2", "Test Road 2", 1, 0.5, 1, 0.2, [])
			# RoadLaneInfo.new(RoadNetwork.Direction.FORWARD, 0.5, 0)
		if event.scancode == KEY_3:
			current_info = RoadNetworkInfo.new("test_id_3", "Test Road 3", 1, 1.5, 1, 0.01, [])
			# RoadLaneInfo.new(RoadNetwork.Direction.FORWARD, 0.5, 0.5), RoadLaneInfo.new(RoadNetwork.Direction.FORWARD, 0.5, 0), RoadLaneInfo.new(RoadNetwork.Direction.FORWARD, 0.5, -0.5)
		if event.scancode == KEY_4:
			current_info = RoadNetworkInfo.new("test_id_4", "Test Road 4", 2, 1, 1)
		if event.scancode == KEY_5:
			current_info = RoadNetworkInfo.new("test_id_5", "Test Road 5", 1, 1, 1.5)
		if event.scancode == KEY_6:
			current_info = RoadNetworkInfo.new("test_id_6", "Test Road 6", 0.25, 0.5, 1, 0.01, [])
			# RoadLaneInfo.new(RoadNetwork.Direction.FORWARD, 0.5, 0)
		if event.scancode == KEY_M:
#			RoadIntersection.new()
	

#	if event is InputEventMouseButton  and current_info:
#		if event.button_index == BUTTON_LEFT and event.pressed:
#			if !_is_dragging: # start a new road
#				if _snapped:
#					_drag_start = create_new_intersection(_snapped.position)
#					$RoadNetwork.add_intersection(_drag_start)
#				elif _snapped_segment:
#					_start_segment = _snapped_segment
#					_drag_start = create_new_intersection(_start_segment.project_point(_cast_ray_to(event.position)))
#					$RoadNetwork.add_intersection(_drag_start)
#				else:
#					var new_intersection = create_new_intersection(_cast_ray_to(event.position))
#					_drag_start = new_intersection
#					$RoadNetwork.add_intersection(_drag_start)
#				_is_dragging = true
#				_snapped = null
#				_snapped_segment = null
#
#			elif _is_dragging: # end the dragging, and create new road in world
#				if (_drag_middle and is_curve_tool_on) or !is_curve_tool_on:
#					if !_drag_middle and is_curve_tool_on:
#						return
#					if !buildable:
#						return
#					if _snapped:
#						_drag_end = create_new_intersection(_snapped.position)
#						$RoadNetwork.add_intersection(_drag_end)
#					elif _snapped_segment:
#						_end_segment = _snapped_segment
#						_drag_end = create_new_intersection(_end_segment.project_point(_cast_ray_to(event.position)))
#						$RoadNetwork.add_intersection(_drag_end)
#					else:
#						var new_intersection = create_new_intersection(_cast_ray_to(event.position))
#						new_intersection = snap_to_length_and_angle(_drag_start, new_intersection)
#						_drag_end = new_intersection
#						$RoadNetwork.add_intersection(_drag_end, false)
#						$RoadNetwork.connect_intersections(_drag_start, _drag_end, current_info)
#
#					var start_intersection = world_road_network.get_closest_node(_drag_start.position)
#					var middle_intersection = null
#					var end_intersection = world_road_network.get_closest_node(_drag_end.position)
#					if !start_intersection:
#						start_intersection = create_new_intersection(_drag_start.position)
#					if !end_intersection:
#						end_intersection = create_new_intersection(_drag_end.position)
#					if _drag_middle:
#						middle_intersection = create_new_intersection(_drag_middle.position)
#
#					# add to world
#					if !world_road_network.has_intersection(start_intersection):
#						world_road_network.add_intersection(start_intersection, false)
#					if !world_road_network.has_intersection(end_intersection):
#						world_road_network.add_intersection(end_intersection, false)
#					if _drag_middle and is_curve_tool_on:
#						if !world_road_network.has_intersection(middle_intersection):
#							world_road_network.add_intersection(middle_intersection, false)
#
##					if _start_segment:
##						if _start_segment is RoadSegment:
##							var segments = world_road_network.split_at_postion(_start_segment, start_intersection, _start_segment.road_network_info)
##							for segment in segments:
##								world_road_network.subdivide_intersections(segment.start_position, segment.end_position, _start_segment.road_network_info)
##						elif _start_segment is RoadBezier:
##							world_road_network.split_at_position_with_bezier(_start_segment, start_intersection, _start_segment.road_network_info)
##					if _end_segment:
##						if _end_segment is RoadSegment:
##							var segments = world_road_network.split_at_postion(_end_segment, end_intersection, _end_segment.road_network_info)
##							for segment in segments:
##								world_road_network.subdivide_intersections(segment.start_position, segment.end_position, _end_segment.road_network_info)
##						elif _end_segment is RoadBezier:
##							world_road_network.split_at_position_with_bezier(_end_segment, end_intersection, _end_segment.road_network_info)
#					if start_intersection.position != end_intersection.position and !is_curve_tool_on:
## warning-ignore:return_value_discarded
#						world_road_network.connect_intersections(start_intersection, end_intersection, current_info, false)
#						world_road_network.subdivide_intersections(start_intersection, end_intersection, current_info, false)
##						print(connection.get_bounds())
#					if middle_intersection and is_curve_tool_on:
#						world_road_network.connect_intersections_with_bezier(start_intersection, middle_intersection, end_intersection, current_info, false)
#	#				world_road_network.draw()
#					world_road_network.update()
#					$RoadNetwork.clear()
#					_is_dragging = continue_dragging
#					if continue_dragging:
#						print(start_intersection, end_intersection)
#						_drag_start = create_new_intersection(_drag_end.position)
#						$RoadNetwork.add_intersection(_drag_start)
#					reset(false, continue_dragging)
#					if !continue_dragging:
#						_drag_start = null
#				else:
#					var new_intersection = create_new_intersection(_cast_ray_to(event.position))
#					new_intersection = snap_to_length_and_angle(_drag_start, new_intersection)
#					_drag_middle = new_intersection
#					$RoadNetwork.add_intersection(_drag_middle)
#
#
#
#
#		if event.button_index == BUTTON_RIGHT and event.pressed:
#			if _is_dragging:
#				reset()
#				$RoadNetwork.clear()
#
#	if event is InputEventMouseMotion and current_info:
#		_snapped = null
#		if _drag_current:
#			$RoadNetwork.remove_intersection(_drag_current, false)
#			_drag_current = null
#
#		var new_intersection = create_new_intersection(_cast_ray_to(event.position))
#		_drag_current = new_intersection
#		$RoadNetwork.add_intersection(_drag_current)
#		if _is_dragging and !is_curve_tool_on:
#			$RoadNetwork.connect_intersections(_drag_start, _drag_current, current_info)
#		_snapped_segment = null
#		_snapped = null
#		if _is_dragging and _drag_middle and is_curve_tool_on:
#			$RoadNetwork.connect_intersections_with_bezier(_drag_start, _drag_middle, _drag_current, current_info)
#		if _is_dragging and !_drag_middle and is_curve_tool_on:
#			$RoadNetwork.connect_intersections(_drag_start, _drag_current, current_info)
#
#		# snap to intersection
#		var closest_segment = world_road_network.get_closest_segment(new_intersection.position, 0.5)
#		if closest_segment:
#			_drag_current.position = closest_segment.project_point(new_intersection.position)
#			_snapped_segment = closest_segment
#
#		var closest_bezier_seg = world_road_network.get_closest_bezier_segment(new_intersection.position, 0.51)
##		print(closest_bezier_seg)
#		if closest_bezier_seg:
#			_drag_current.position = closest_bezier_seg.project_point(new_intersection.position)
#			_snapped_segment = closest_bezier_seg
#
#		# snap to edge
#
#		if _is_dragging:
#			var direction = _drag_start.direction_to(_drag_current)
#			var angle = abs(rad2deg(atan2(direction.z, direction.x)))
#			if _drag_start.distance_to(_drag_current) < 1 and angle < 15 and !is_equal_approx(angle, 0):
#				if $RoadNetwork/RoadRenderer.material_overlay != non_buildable_mat:
#					$RoadNetwork/RoadRenderer.material_overlay = non_buildable_mat
#				buildable = false
#			elif _drag_start.distance_to(_drag_current) > 1 and angle > 15 or is_equal_approx(angle, 0):
#				if $RoadNetwork/RoadRenderer.material_overlay != buildable_mat:
#					$RoadNetwork/RoadRenderer.material_overlay = buildable_mat
#				buildable = true
#
#		elif !_is_dragging and $RoadNetwork/RoadRenderer.material_overlay != buildable_mat:
#			$RoadNetwork/RoadRenderer.material_overlay = buildable_mat
#
#		# snap the length and angle
#		if _is_dragging:
#			if _drag_middle and is_curve_tool_on:
#				_drag_current = snap_to_length_and_angle(_drag_middle, _drag_current)
#			else:
#				_drag_current = snap_to_length_and_angle(_drag_start, _drag_current)
#
#		var closest_node = world_road_network.get_closest_node(new_intersection.position)
#		if closest_node:
#			_snapped = closest_node
#			_drag_current.position = _snapped.position
#
#		$RoadNetwork.draw()
#		$RoadNetwork/RoadRenderer.update()

# if !_is_dragging:
##					prints(_drag_current.position == closest_point, dist < 1)
#				_drag_current.position = closest_point
#				_snapped_segment = segment
##					prints(_drag_start, _drag_end, _drag_current, _start_segment, _end_segment, _snapped_segment, closest_point, dist)
#			elif _is_dragging and is_instance_valid(_drag_start) and is_instance_valid(_drag_current) and _drag_start.position != closest_point:
#				_drag_current.position = closest_point
#				_snapped_segment = segment

func _process(_delta):
	if _is_dragging and is_instance_valid(_drag_current):
		var camera = get_viewport().get_camera()
		var position = camera.unproject_position(_drag_current.position)
		if is_vec_nan(position):
			return
		$"Control/PanelContainer".rect_position = position-$"Control/PanelContainer".rect_size/2
		var length = _drag_start.distance_to(_drag_current)
		if !is_equal_approx(length, 0.01):
			$Control/PanelContainer/Label.text = "%.2fu" % length
			$Control/PanelContainer.show()
		var angle_pos = camera.unproject_position(_drag_start.position)
		if is_vec_nan(angle_pos):
			return
		$"Control/PanelContainer2".rect_position = angle_pos-$Control/PanelContainer2.rect_size/2
		var direction = _drag_start.direction_to(_drag_current)
		var angle = rad2deg(atan2(direction.z, direction.x))
		$Control/PanelContainer2/Label.text = "%.2f deg" % angle
		$Control/PanelContainer2.show()
	if !_is_dragging:
		$Control/PanelContainer.hide()
		$Control/PanelContainer2.hide()


func _set_snapped(new_intersection: RoadIntersection):
	_snapped = world_road_network.get_closest_node(new_intersection.position)
	if _drag_start and _snapped and _snapped.position == _drag_start.position:
		return
	if _snapped and _drag_current:
		_drag_current.position = _snapped.position

func reset(reset_start = true, _dragging = false):
	_drag_current = null
	if reset_start:
		_drag_start = null
	_drag_middle = null
	_drag_end = null
	_start_segment = null
	_end_segment = null
	_snapped_segment = null
	if !_dragging:
		_is_dragging = false
	_snapped = null

func _cast_ray_to(postion: Vector2):
	var camera = get_viewport().get_camera()
	var from = camera.project_ray_origin(postion)
	var to = from + camera.project_ray_normal(postion) * camera.far
	return get_world().direct_space_state.intersect_ray(from, to).get("position", Vector3(NAN, NAN, NAN))

func create_new_intersection(position) -> RoadIntersection:
	return current_info.create_intersection(position)

func snap_to_length_and_angle(from, to):
	var length = from.distance_to(to)
	var direction = from.direction_to(to)
	var angle = rad2deg(atan2(direction.z, direction.x))
	var new_length = round(length / 2.5) * 2.5
	var new_angle = round(angle / 45.0) * 45.0
	if abs(angle - new_angle) < 5:
		angle = new_angle
		direction = Vector3(cos(deg2rad(angle)), 0, sin(deg2rad(angle)))
		to.position = from.position + direction * length
	if abs(length - new_length) < 0.25 and new_length != 0:
		length = new_length
		to.position = from.position + direction * length
	return to

func is_vec_nan(vec) -> bool:
	if typeof(vec) == TYPE_VECTOR3:
		return is_nan(vec.x) and is_nan(vec.y) and is_nan(vec.z)
	if typeof(vec) == TYPE_VECTOR2:
		return is_nan(vec.x) and is_nan(vec.y)
	if typeof(vec) == TYPE_REAL:
		return is_nan(vec)
	return false
