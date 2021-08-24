extends Spatial

export(NodePath) var world_road_network_node
onready var world_road_network: RoadNetwork = get_node(world_road_network_node)


const RoadIntersection = RoadNetwork.RoadIntersection

var pathfind_start: RoadIntersection
var pathfind_current: RoadIntersection

var enable_tool = false
func _input(event):
	if event is InputEventKey:
		if event.scancode == KEY_T:
			enable_tool = true
		if event.scancode == KEY_Y:
			enable_tool = false

	if !enable_tool:
		return

	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			if !pathfind_start:
				var snapped = world_road_network.get_closest_node(_cast_ray_to(event.position), 0.75)
				if snapped:
					$RoadNetwork.add_intersection(snapped)
					$RoadNetwork.draw(Color.yellowgreen, Color.chartreuse)
					pathfind_start = snapped
				
			elif pathfind_start:
				var snapped = world_road_network.get_closest_node(_cast_ray_to(event.position), 0.75)
				if snapped:
					$RoadNetwork.add_intersection(snapped)
					var path = world_road_network.find_path(pathfind_start, snapped)
					add_path_to_network(path, $RoadNetwork)
					
					$RoadNetwork.draw(Color.yellowgreen, Color.chartreuse)
					
					$RoadNetwork.clear()
					pathfind_start = null
	
	if event is InputEventMouseMotion:
		if !pathfind_start:
			var snapped = world_road_network.get_closest_node(_cast_ray_to(event.position), 0.75)
			if snapped:
				$RoadNetwork.add_intersection(snapped)
				$RoadNetwork.draw(Color.yellowgreen, Color.chartreuse)
				$RoadNetwork.remove_intersection(snapped, true)
		elif pathfind_start:
			var snapped = world_road_network.get_closest_node(_cast_ray_to(event.position), 0.75)
			if snapped:
				$RoadNetwork.add_intersection(snapped)
				var path = world_road_network.find_path(pathfind_start, snapped)
				add_path_to_network(path, $RoadNetwork)
				$RoadNetwork.draw(Color.yellowgreen, Color.chartreuse)
				remove_path_from_network(path, $RoadNetwork)
				$RoadNetwork.remove_intersection(snapped, true)
				

func add_path_to_network(path, network: RoadNetwork):
	var previous_point = null
	for point in path:
		if previous_point == null:
			previous_point = point
			continue
		if !network.has_intersection(point):
			network.add_intersection(point)
		network.connect_intersections(previous_point, point)
		previous_point = point

func remove_path_from_network(path, network: RoadNetwork):
	var previous_point = null
	for point in path:
		if previous_point == null:
			previous_point = point
			continue
		if network.has_intersection(point):
			network.remove_intersection(point, true)
		network.disconnect_intersections(previous_point, point)
		previous_point = point

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
