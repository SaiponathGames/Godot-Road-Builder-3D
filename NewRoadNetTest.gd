extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var segment = null
var currently_hovering_seg = null

var viewport_mode = {
	0: "Default",
	1: "Unshaded",
	2: "Overdraw",
	3: "Wireframe"
}
func _init():
	VisualServer.set_debug_generate_wireframes(true)

# Called when the node enters the scene tree for the first time.
func _ready():
	Engine.iterations_per_second = OS.get_screen_refresh_rate(OS.current_screen)
	
#	yield(get_tree().create_timer(1), "timeout")
#	OS.window_maximized = true
#	yield(get_tree().create_timer(1), "timeout")
#	var two_lane_info = RoadNetworkInfoRegister.find("*two_lane*")[0]
#	var four_lane_info = RoadNetworkInfoRegister.find("*four_lane*")[0]
#	var inter_1 = RoadIntersection.new(Vector3(2, 0, 1), two_lane_info)
#	var inter_2 = RoadIntersection.new(Vector3(8, 0, 5), two_lane_info)
#	var inter_3 = RoadIntersection.new(Vector3(15, 0, 25), two_lane_info)
#	prints("IDs: ", inter_1.get_id($HTerrain/RoadNetwork.min_vector), inter_2.get_id($HTerrain/RoadNetwork.min_vector))
#	var segment = RoadSegmentLinear.new(inter_1, inter_2, two_lane_info, RoadSegmentBase.BIDIRECTIONAL)
#	var segment1 = RoadSegmentLinear.new(inter_2, inter_3, two_lane_info, RoadSegmentBase.BIDIRECTIONAL)
#	segment = $HTerrain/RoadNetwork.create_segment(segment)
#	segment1 = $HTerrain/RoadNetwork.create_segment(segment1)
#	$HTerrain/RoadNetwork.update()
#	print(segment)
#	print(segment1)
#	print($HTerrain/RoadNetwork.get_all_segments_from_to(inter_1, inter_2))
#	$HTerrain/RoadNetwork.upgrade_segment(segment, four_lane_info)
#	print($HTerrain/RoadNetwork.get_all_segments_from_to(inter_1, inter_2)[0].road_network_info == four_lane_info)
	draw()
#	var query_point = Vector3(2, 0, 1.5)
#	var _im_geo = $HTerrain/ImmediateGeometry
#	DrawingUtils.draw_empty_circle(im_geo, query_point, 0.25, Color.yellow)
#	DrawingUtils.draw_empty_circle(im_geo, query_point, 1, Color.yellow)
#	DrawingUtils.draw_box_with_aabb(im_geo, inter_1.get_aabb(), Color.tan)
#	DrawingUtils.draw_box_with_aabb(im_geo, inter_2.get_aabb(), Color.tan)
#	DrawingUtils.draw_box_with_aabb(im_geo, $HTerrain/RoadNetwork._get_aabb_to_test(query_point), Color.tan)
#	var point = $HTerrain/RoadNetwork.get_closest_point_to(query_point, 1)
#	DrawingUtils.draw_line(im_geo, inter_1.position, inter_2.position, Color.aqua)
#	var segment = $HTerrain/RoadNetwork.get_closest_segment_to()
#	if point:
#		DrawingUtils.draw_box_with_aabb(im_geo, $HTerrain/RoadNetwork._get_aabb_to_test(query_point), Color.red)
#		DrawingUtils.draw_empty_circle(im_geo, query_point, 1, Color.red)
#		DrawingUtils.draw_empty_circle(im_geo, point.position, 0.25, Color.lightcoral)
#	var id = 9223372036854775807
#			#8590034993793
##	print($HTerrain/RoadNetwork.get_segment(inter_1, inter_2))
#	print(stepify(id/1000.0, 0.001))
#	print(float(id)/100.0)
#	$HTerrain/RoadNetwork.delete_segment(segment)

func _input(event):
	if event is InputEventMouseMotion:
		var pos = event.position
		var pos_3d = _cast_ray_to(pos)
		currently_hovering_seg = $HTerrain/GlobalRoadNetwork.get_closest_segment_to(pos_3d, 1)
		var inter = $HTerrain/GlobalRoadNetwork.get_closest_point_to(pos_3d, 1)
		if inter:
			currently_hovering_seg = inter
	if event is InputEventKey:
		if event.scancode == KEY_Y:
			$HTerrain/Camera.target_tilt_rotation.x = 90
			$HTerrain/Camera.target_tilt_rotation.x = -90

func _cast_ray_to(position: Vector2):
	var camera = get_viewport().get_camera()
	var from = camera.project_ray_origin(position)
	var to = from + camera.project_ray_normal(position) * camera.far
	return get_world().direct_space_state.intersect_ray(from, to).get("position", Vector3(NAN, NAN, NAN))


func _unhandled_key_input(event: InputEventKey):
	if event.scancode == KEY_KP_0 and event.pressed and !event.echo:
		OS.shell_open(ProjectSettings.globalize_path("user://logs/"))
		$HTerrain/GlobalRoadNetwork/QuadTree.dump("test")
		OS.shell_open(ProjectSettings.globalize_path("user://dumps/test.txt"))
		
	var two_lane_info = RoadNetworkInfoRegister.find("*two_lane*")[0]
	var four_lane_info = RoadNetworkInfoRegister.find("*four_lane*")[0]
	if !event.shift and !event.alt and !event.control:
		if event.scancode == KEY_KP_ADD and event.pressed:
			get_viewport().debug_draw = wrapi(get_viewport().debug_draw+1, 0, 4)
		elif event.scancode == KEY_KP_SUBTRACT and event.pressed:
			get_viewport().debug_draw = wrapi(get_viewport().debug_draw-1, 0, 4)
		elif event.scancode == KEY_KP_MULTIPLY and event.pressed:
			get_viewport().debug_draw = Viewport.DEBUG_DRAW_DISABLED
		elif event.scancode == KEY_M and event.pressed:
			OS.window_maximized = !OS.window_maximized
		elif event.scancode == KEY_N and event.pressed:
			OS.window_fullscreen = !OS.window_fullscreen
		elif event.scancode == KEY_KP_1 and event.pressed:
			var previous_pos = Vector3(rand_range(0, 1275), 0, rand_range(0, 1275))
			var previous_intersection = RoadIntersection.new(previous_pos, two_lane_info)
			var position_inters = [previous_intersection]
			var positions = [previous_pos]
			var rect = AABB(Vector3(0, 0, 0), Vector3(1275, 0, 1275))
			for i in rand_range(1, 1):
				var intersection_1 = pick_random(position_inters) if rand_range(1, 1) == 1 and !position_inters.empty() else previous_intersection
				var segment_1 = create_linear(intersection_1, rect)
				if segment_1:
					previous_intersection = segment_1.end_position.intersection
					previous_pos = previous_intersection.position
					positions.append(previous_pos)
					position_inters.append(previous_intersection)
				else:
					break
			$HTerrain/GlobalRoadNetwork.update()
			var mid_position = sum_array(positions)/positions.size()
			# move camera to the segment
			$HTerrain/Camera.target_translation = mid_position
		elif event.scancode == KEY_KP_2 and event.pressed:
			segment = pick_random($HTerrain/GlobalRoadNetwork.get_all_segments_of_type(RoadSegmentLinear))
			if is_instance_valid(segment):
				$HTerrain/Camera.target_translation = segment.position
		elif event.scancode in [KEY_KP_3, KEY_KP_6] and event.pressed:
			if is_instance_valid(segment):
				$HTerrain/GlobalRoadNetwork.delete_segment(segment)
				segment.call_deferred('free')
				$HTerrain/GlobalRoadNetwork.update()
		elif event.scancode == KEY_KP_4 and event.pressed:
			var rect = AABB(Vector3(0, 0, 0), Vector3(1275, 0, 1275))
			var last_bez_pos = RoadIntersection.new(Vector3(rand_range(0, 1275), 0, rand_range(0, 1275)), two_lane_info)
			var positions = []
			var position_inters = []
			for _i in rand_range(1, 1):
				var inter_1 =  pick_random(position_inters) if randi() % 10 == 0 and !position_inters.empty() else last_bez_pos
				var segment_1 = create_bezier(inter_1, rect)
				if segment_1:
					last_bez_pos = segment_1.end_position.intersection
					positions.append(last_bez_pos.position)
					position_inters.append(last_bez_pos)
					
				else:
					break
			$HTerrain/GlobalRoadNetwork.update()
			
			var mid_pos = sum_array(positions)/positions.size()
			$HTerrain/Camera.target_translation = mid_pos
		elif event.scancode == KEY_KP_5 and event.pressed:
			segment = pick_random($HTerrain/GlobalRoadNetwork.get_all_segments_of_type(RoadSegmentBezier))
			if is_instance_valid(segment):
				$HTerrain/Camera.target_translation = segment.position
	elif event.alt:
		if event.scancode == KEY_KP_1 and event.pressed:
			print("activating?")
			var previous_pos = Vector3(rand_range(0, 1275), 0, rand_range(0, 1275))
			var previous_intersection = RoadIntersection.new(previous_pos, two_lane_info)
			var position_inters = [previous_intersection]
			var positions = [previous_pos]
			var rect = AABB(Vector3(0, 0, 0), Vector3(1275, 0, 1275))
			for i in rand_range(1, 1):
				var intersection_1 = pick_random(position_inters) if rand_range(1, 1) == 1 and !position_inters.empty() else previous_intersection
				var segment_1 := create_linear(intersection_1, rect, 80)
				if segment_1:
					var start_pos = segment_1.start_position.intersection.position
					var end_pos = segment_1.end_position.intersection.position
					var mid_pos = RoadIntersection.new((start_pos+end_pos) / 2, two_lane_info)
					print("Splitting road segment")
					segment_1.split_at_position(mid_pos)
			$HTerrain/GlobalRoadNetwork.update()
#			$HTerrain/GlobalBuildingNetwork/QuadTreeNode.dump()
			$HTerrain/Camera.target_translation = previous_pos
	
	
#var inter_1pos = Vector3(rand_range(0, 1275), 0, rand_range(0, 1275))
#		var inter_1 = RoadIntersection.new(inter_1pos, two_lane_info)
#		var inter_2 = RoadIntersection.new(Vector3(_move_distance_in_direction(inter_1pos, rand_range(10, 30), deg2rad(rand_range(-45, 135)))), two_lane_info)
#		var inter_3 = RoadIntersection.new(Vector3(_move_distance_in_direction(inter_2.position, rand_range(20, 40), deg2rad(rand_range(-45, 135)))), two_lane_info)
##		prints("IDs: ", inter_1.get_id($HTerrain/RoadNetwork.min_vector), inter_2.get_id($HTerrain/RoadNetwork.min_vector))
#		var segment = RoadSegmentLinear.new(inter_1, inter_2, two_lane_info, RoadSegmentBase.BIDIRECTIONAL)
#		var segment1 = RoadSegmentLinear.new(inter_2, inter_3, two_lane_info, RoadSegmentBase.BIDIRECTIONAL)
#		segment = $HTerrain/RoadNetwork.create_segment(segment)
#		segment1 = $HTerrain/RoadNetwork.create_segment(segment1)
#		$HTerrain/RoadNetwork.update()
func draw():
	$HTerrain/ImmediateGeometry.clear()
	var road_net = $HTerrain/GlobalRoadNetwork
	var im_geo = $HTerrain/ImmediateGeometry
	for road_inter in road_net.graph_inter_map.values():
		DrawingUtils.draw_empty_circle(im_geo, road_inter.position, 0.25)
	for road_seg in road_net.graph_seg_map.values():
		match road_seg.renderer:
			RoadSegmentBaseRenderer:
				DrawingUtils.draw_line(im_geo, road_seg.start_position.position, road_seg.end_position.position, Color.aqua)
			RoadSegmentBezierRenderer:
#				print("rendering")
				DrawingUtils.draw_line(im_geo, road_seg.start_position.position, road_seg.middle_position.position, Color.aqua)				
				DrawingUtils.draw_line(im_geo, road_seg.middle_position.position, road_seg.end_position.position, Color.aqua)				
func sum_array(arr: Array) -> Vector3:
	var result: Vector3
	for value in arr:
		result += value
	return result

func _notification(what):
	match what:
		NOTIFICATION_EXIT_WORLD:
			clear_segments($HTerrain/GlobalRoadNetwork)

func _move_distance_in_direction(position, dist, direction):
	return position + (Vector3(cos(direction), 0, sin(direction)) * dist)

func clear_segments(road_net):
	for segment in road_net.graph_seg_map.values():
		road_net.delete_segment(segment)

func pick_random(arr: Array):
	if arr.empty():
		return null
	return arr[randi() % arr.size()]


func _on_RoadNetwork_graph_changed(_road_net):
	call_deferred('draw')

func create_bezier(inter1, rect):
	var two_lane_info = RoadNetworkInfoRegister.find("*two_lane*")[0]
	var four_lane_info = RoadNetworkInfoRegister.find("*four_lane*")[0]
	
	var inter2_pos = _move_distance_in_direction(inter1.position, rand_range(5, 10), deg2rad(rand_range(45, 145)))
	var inter2 = RoadIntersection.new(inter2_pos, two_lane_info)
	
	var inter3_pos = _move_distance_in_direction(inter2_pos, rand_range(10, 15), deg2rad(rand_range(45, 135)))
	var inter3 = RoadIntersection.new(inter3_pos, two_lane_info)
	if !rect.has_point(inter3_pos):
		return
	var bez_seg = RoadSegmentBezier.new(inter1, inter2, inter3, two_lane_info, RoadSegmentBase.BIDIRECTIONAL)
	$HTerrain/GlobalRoadNetwork.create_segment(bez_seg)
	return bez_seg

func create_linear(inter1, rect, distance = null) -> RoadSegmentLinear:
	var two_lane_info = RoadNetworkInfoRegister.find("*two_lane*")[0]
	var four_lane_info = RoadNetworkInfoRegister.find("*four_lane*")[0]
	var start_pos_int = inter1.position
	var dist = rand_range(10, 30)
	if distance:
		dist = distance
		
	var position = _move_distance_in_direction(start_pos_int, dist, deg2rad(rand_range(-90, 90)))
	if !rect.has_point(position):
		return null
	var inter_2 = RoadIntersection.new(position, two_lane_info)
	var start_pos = inter1
	var segment = RoadSegmentLinear.new(start_pos, inter_2, two_lane_info, RoadSegmentBase.BIDIRECTIONAL)
	$HTerrain/GlobalRoadNetwork.create_segment(segment)
	return segment

# pick_random(positions) if randi() % 10 == 0 and !positions.empty() else inter1_pos

func _physics_process(delta):
	DebugConsole.add_text("Engine: FPS %s" % Engine.get_frames_per_second())
	DebugConsole.add_text("Viewport: Viewmode %s" % viewport_mode.get(get_viewport().debug_draw))
	if not is_instance_valid(currently_hovering_seg):
		return
	if currently_hovering_seg is RoadSegmentBase:
		DebugConsole.add_text("Currently Hovering Segment: %s" % currently_hovering_seg)
	elif currently_hovering_seg is RoadIntersection:
		DebugConsole.add_text("Currently Hovering Intersection: %s" % currently_hovering_seg)
		
