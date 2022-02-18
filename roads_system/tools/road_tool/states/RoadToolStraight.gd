extends Spatial


var _drag_start: RoadIntersection
var _drag_end: RoadIntersection
var _drag_current: RoadIntersection
var _is_dragging: bool

var _continue_dragging = true

var _cache_previous_segment: RoadSegmentBase
var _enabled: bool

var local_road_network: RoadNetwork
var global_road_network: RoadNetwork

var road_net_info: RoadNetworkInfo

func _input(event: InputEvent):
	if !_enabled:
		return
	
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == BUTTON_LEFT:
			if !_is_dragging:
				setup_dragging(event)
			elif _is_dragging:
				stop_dragging(event)
		elif event.pressed and event.button_index == BUTTON_RIGHT:
			if _is_dragging:
				cancel_dragging(event)
	if event is InputEventMouseMotion:
		continue_dragging(event)

func cancel_dragging(_event: InputEvent):
	_drag_start = null
	_drag_current = null
	_drag_end = null
	_is_dragging = false
	if _cache_previous_segment:
		local_road_network.delete_segment(_cache_previous_segment)
		_cache_previous_segment.free()
	_cache_previous_segment = null
	print("cancelled")

func setup_dragging(event: InputEventMouseButton):
	_drag_start = RoadIntersection.new(_cast_ray_to(event.position), road_net_info)
	_is_dragging = true
	print("started")

func stop_dragging(event: InputEventMouseButton):
	_drag_end = RoadIntersection.new(_cast_ray_to(event.position), road_net_info)
	_is_dragging = false
	
	var segment = RoadSegmentLinear.new(_drag_start, _drag_end, road_net_info, RoadSegmentLinear.FORWARD)
	segment = global_road_network.create_segment(segment)
	print("stopped")
	local_road_network.delete_segment(_cache_previous_segment)
	_cache_previous_segment.free()
	_cache_previous_segment = null
	
	if _continue_dragging:
		_drag_start = _drag_end
		_drag_end = null
		_is_dragging = true
	else:
		_drag_start = null
		_drag_end = null
	
func continue_dragging(event: InputEventMouseMotion):
	_drag_current = RoadIntersection.new(_cast_ray_to(event.position), road_net_info)
	if _cache_previous_segment:
		local_road_network.delete_segment(_cache_previous_segment)
		_cache_previous_segment.free()
		_cache_previous_segment = null
		print_debug(_drag_start, _drag_current)
	if _drag_start and _drag_start.distance_to(_drag_current) > 1:
		_cache_previous_segment = RoadSegmentLinear.new(_drag_start, _drag_current, road_net_info, RoadSegmentLinear.FORWARD)
		_cache_previous_segment = local_road_network.create_segment(_cache_previous_segment)

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

func _ready():
	road_net_info = RoadNetworkInfoRegister.find("*two_lane*")[0]
