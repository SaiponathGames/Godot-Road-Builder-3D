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
	_drag_start.set_meta("_auto_delete", false)
	_is_dragging = true
	print("started")

func stop_dragging(event: InputEventMouseButton):
	_drag_end = RoadIntersection.new(_cast_ray_to(event.position), road_net_info)
	_is_dragging = false
	
	var segment = RoadSegmentLinear.new(_drag_start.duplicate(), _drag_end.duplicate(), road_net_info, RoadSegmentLinear.FORWARD)
	segment = global_road_network.create_segment(segment)
	global_road_network.update()
	print("stopped")
	if is_instance_valid(_cache_previous_segment):
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
	var previous_drag_current
	var previous_cache_segment
	if is_instance_valid(_drag_start):
		previous_drag_current = _drag_current
		previous_cache_segment = _cache_previous_segment
		_drag_current = RoadIntersection.new(_cast_ray_to(event.position), road_net_info)
	
		
	if is_instance_valid(previous_cache_segment):
		print(_cache_previous_segment)
		local_road_network.delete_segment(previous_cache_segment)
		previous_cache_segment.free()
		previous_cache_segment = null
		
	if _drag_start and _drag_start.distance_to(_drag_current) > 1:
		_cache_previous_segment = RoadSegmentLinear.new(_drag_start.duplicate(), _drag_current, road_net_info, RoadSegmentLinear.FORWARD)
		_cache_previous_segment = local_road_network.create_segment(_cache_previous_segment)
		local_road_network.update()
		
#	if is_instance_valid(previous_drag_current):
#		previous_drag_current.free()

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
