extends Spatial


var _drag_start: RoadIntersection
var _drag_end: RoadIntersection
var _drag_current: RoadIntersection
var _is_dragging: bool

var _enabled: bool

var local_road_network: RoadNetwork

func _input(event: InputEvent):
	if !_enabled:
		return
	
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == BUTTON_LEFT:
			if !_is_dragging:
				setup_dragging(event)
			elif _is_dragging:
				stop_dragging(event)
	if event is InputEventMouseMotion:
		continue_dragging(event)

func setup_dragging(event: InputEventMouseButton):
	_drag_start = RoadIntersection.new(_cast_ray_to(event.position), RoadNetworkInfoRegister.find("*two_lane*")[0])
	_is_dragging = true

func stop_dragging(event: InputEventMouseButton):
	_drag_end = RoadIntersection.new(_cast_ray_to(event.position), RoadNetworkInfoRegister.find("*two_lane*")[0])
	_is_dragging = false
	
	var segment = RoadSegmentLinear.new(_drag_start, _drag_end, RoadNetworkInfoRegister.find("*two_lane*")[0], RoadSegmentLinear.FORWARD)
	local_road_network.create_segment(segment)
	
func continue_dragging(event: InputEventMouseMotion):
	pass

func set_enabled(value: bool):
	_enabled = value

func _cast_ray_to(position: Vector2):
	var camera = get_viewport().get_camera()
	var from = camera.project_ray_origin(position)
	var to = from + camera.project_ray_normal(position) * camera.far
	return get_world().direct_space_state.intersect_ray(from, to).get("position", Vector3(NAN, NAN, NAN))

func is_vec_nan(vec) -> bool:
	if typeof(vec) == TYPE_VECTOR3:
		return is_nan(vec.x) and is_nan(vec.y) and is_nan(vec.z)
	if typeof(vec) == TYPE_VECTOR2:
		return is_nan(vec.x) and is_nan(vec.y)
	if typeof(vec) == TYPE_REAL:
		return is_nan(vec)
	return false

