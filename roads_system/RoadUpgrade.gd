extends Spatial

export(NodePath) var world_road_network_node
onready var world_road_network: RoadNetwork = get_node(world_road_network_node) as RoadNetwork

const RoadIntersection = RoadNetwork.RoadIntersection
const RoadSegment = RoadNetwork.RoadSegment
const RoadNetworkInfo = RoadNetwork.RoadNetworkInfo

var _snapped_segment: RoadSegment

var enabled = false

var current_info: RoadNetworkInfo = RoadNetworkInfo.new("test_id", "Test Road", 1, 0.5, 1)

func _input(event):
	if event is InputEventKey:
		if event.scancode == KEY_G:
			enabled = true
			show()
		if event.scancode == KEY_H:
			enabled = false
			hide()
			reset()
			$RoadNetwork.clear()
				
		if event.scancode == KEY_1:
			current_info = RoadNetworkInfo.new("test_id", "Test Road", 1, 0.5, 1)
		if event.scancode == KEY_2:
			current_info = RoadNetworkInfo.new("test_id_2", "Test Road 2", 1, 1, 1)
		if event.scancode == KEY_3:
			current_info = RoadNetworkInfo.new("test_id_3", "Test Road 3", 1, 1.5, 1)
		if event.scancode == KEY_4:
			current_info = RoadNetworkInfo.new("test_id_4", "Test Road 4", 2, 1, 1)
		if event.scancode == KEY_5:
			current_info = RoadNetworkInfo.new("test_id_4", "Test Road 4", 1, 1, 1.5)
		
		
	if !enabled:
		return
		
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_RIGHT:
			var position = _cast_ray_to(event.position)
			var closest_segment = world_road_network.get_closest_segment(position, 0.5)
			if closest_segment:
				world_road_network.upgrade_connection(closest_segment.start_position, closest_segment.end_position, current_info)
			_snapped_segment = null
			$RoadNetwork.clear()
		
	if event is InputEventMouseMotion:
		var position = _cast_ray_to(event.position)
		var closest_segment = world_road_network.get_closest_segment(position, 0.5)
		$RoadNetwork.clear()
		if closest_segment:
			_snapped_segment = closest_segment
			
			var start_position = create_new_intersection(closest_segment.start_position.position, current_info)
			var end_position = create_new_intersection(closest_segment.end_position.position, current_info)
			
			$RoadNetwork.add_intersection(start_position)
			$RoadNetwork.add_intersection(end_position)
			$RoadNetwork.connect_intersections(start_position, end_position, current_info)

func reset():
	_snapped_segment = null
	
func _cast_ray_to(postion: Vector2):
	var camera = get_viewport().get_camera()
	var from = camera.project_ray_origin(postion)
	var to = from + camera.project_ray_normal(postion) * camera.far
	return get_world().direct_space_state.intersect_ray(from, to).get("position", Vector3(NAN, NAN, NAN))


func create_new_intersection(position, road_info: RoadNetworkInfo) -> RoadIntersection:
	return road_info.create_intersection(position)
