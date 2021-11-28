extends Spatial

export(NodePath) var world_road_network_node
onready var world_road_network = get_node(world_road_network_node) as RoadNetwork


const RoadIntersection = RoadNetwork.RoadIntersection
const RoadNetworkInfo = RoadNetwork.RoadNetworkInfo
const RoadLaneInfo = RoadNetwork.RoadLaneInfo

var pathfind_start: RoadIntersection
var pathfind_current: RoadIntersection

var enabled = false

func _input(event):
	if event is InputEventKey:
		if event.scancode == KEY_O and event.pressed:
			enabled = !enabled
	
	if !enabled:
		return

	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			if !pathfind_start:
				var snapped = world_road_network.get_closest_node(_cast_ray_to(event.position), 0.75)
				if snapped:
					snapped = snapped.road_network_info.create_intersection(snapped.position)
					$RoadNetwork.add_intersection(snapped)
					pathfind_start = snapped
			elif pathfind_start:
				$RoadNetwork.clear()
				pathfind_start = null
				pathfind_current = null
		if event.button_index == BUTTON_RIGHT and event.pressed:
			if pathfind_start:
				$RoadNetwork.clear()
				pathfind_start = null
				pathfind_current = null
				
	if event is InputEventMouseMotion:
		if !pathfind_start:
			var snapped = world_road_network.get_closest_node(_cast_ray_to(event.position), 0.75)
			if snapped:
				if pathfind_current:
					$RoadNetwork.remove_intersection(pathfind_current)
				snapped = snapped.road_network_info.create_intersection(snapped.position)
				$RoadNetwork.add_intersection(snapped)
				pathfind_current = snapped
#				$RoadNetwork.remove_intersection(snapped, true)
		elif pathfind_start:
			var snapped = world_road_network.get_closest_node(_cast_ray_to(event.position), 0.75)
			if snapped:
				snapped = snapped.road_network_info.create_intersection(snapped.position)
				$RoadNetwork.add_intersection(snapped)
				$RoadNetwork.clear()
				var path = world_road_network.find_path(pathfind_start, snapped)
				add_path_to_network(path, $RoadNetwork)
				$RoadNetwork.clear(false)
#				$RoadNetwork.remove_intersection(snapped, true)


func add_path_to_network(path, network: RoadNetwork):
	var previous_point = null
	var new_previous_point = null # this network's point
	for point in path:
		if previous_point == null:
			previous_point = point
			new_previous_point = create_intersection(point) # this network's 
			if !network.has_intersection(new_previous_point):
				network.add_intersection(new_previous_point)
			continue
		var new_point = create_intersection(point)
		if !network.has_intersection(new_point):
			network.add_intersection(new_point)
# warning-ignore:return_value_discarded
#		print(world_road_network.get_connection(previous_point, point))
		network.connect_intersections(new_previous_point, new_point, world_road_network.get_connection(previous_point, point, true).road_network_info)
		previous_point = point
		new_previous_point = new_point

#func remove_path_from_network(path, network: RoadNetwork):
#	var previous_point = null
#	for point in path:
#		if previous_point == null:
#			previous_point = point
#			continue
#		if network.has_intersection(point):
#			network.remove_intersection(point, true)
#		network.disconnect_intersections(previous_point, point)
#		previous_point = point

func _cast_ray_to(postion: Vector2):
	var camera = get_viewport().get_camera()
	var from = camera.project_ray_origin(postion)
	var to = from + camera.project_ray_normal(postion) * camera.far
	return get_world().direct_space_state.intersect_ray(from, to).get("position", Vector3(NAN, NAN, NAN))

func draw_path(immediate_geo: ImmediateGeometry, path: Array, color: Color = Color.yellowgreen):
	immediate_geo.begin(Mesh.PRIMITIVE_LINES)
	var previous_point = null
	for point in path:
		if previous_point == null:
			previous_point = point
			continue
		DrawingUtils.draw_line($ImmediateGeometry, previous_point.position, point.position, color)
		previous_point = point
	immediate_geo.end()

func create_intersection(intersection: RoadIntersection):
	return intersection.road_network_info.create_intersection(intersection.position)

#	if event is InputEventMouseMotion:
#		if !pathfind_start:
#			var snapped = world(_cast_ray_to(event.position), 0.75)
#			$ImmediateGeometry.clear()
#			$RoadNetwork.draw()
#			if snapped:
#				DrawingUtils.draw_empty_circle($ImmediateGeometry, snapped.position, 0.5, Color.chartreuse)
#		elif pathfind_start:
#			var snapped = _calculate_snapped(_cast_ray_to(event.position), 0.75)
#			$ImmediateGeometry.clear()
#			draw($ImmediateGeometry)
#			DrawingUtils.draw_empty_circle($ImmediateGeometry, pathfind_start.position, 0.5, Color.chartreuse)
#			if snapped:
#				DrawingUtils.draw_empty_circle($ImmediateGeometry, snapped.position, 0.5, Color.chartreuse)
#				var shortest_path = find_path(pathfind_start, snapped, true)
#				draw_path($ImmediateGeometry, shortest_path)
#
#	if event is InputEventMouseButton:
#		if event.button_index == BUTTON_LEFT and event.pressed:
#			if !pathfind_start:
#				var snapped = _calculate_snapped(_cast_ray_to(event.position), 0.75)
#				$ImmediateGeometry.clear()
#				draw($ImmediateGeometry)
#				if snapped:
#					DrawingUtils.draw_empty_circle($ImmediateGeometry, snapped.position, 0.5, Color.chartreuse)
#					pathfind_start = snapped
#			elif pathfind_start:
#				var snapped = _calculate_snapped(_cast_ray_to(event.position), 0.75)
#				$ImmediateGeometry.clear()
#				draw($ImmediateGeometry)
#				DrawingUtils.draw_empty_circle($ImmediateGeometry, pathfind_start.position, 0.5, Color.chartreuse)
#				if snapped:
#					DrawingUtils.draw_empty_circle($ImmediateGeometry, snapped.position, 0.5, Color.chartreuse)
#					var shortest_path = find_path(pathfind_start, snapped, true)
#					draw_path($ImmediateGeometry, shortest_path)
