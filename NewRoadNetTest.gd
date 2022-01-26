extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
#	yield(get_tree().create_timer(1), "timeout")
#	OS.window_maximized = true
#	yield(get_tree().create_timer(1), "timeout")
	var road_net_info = RoadNetworkInfo.new('test', 'test', 0.4, 0.5, 0.6, 10)
	var road_net_info_1 = RoadNetworkInfo.new('test_1', 'test_1', 0.4, 0.5, 0.6, 10)
	var inter_1 = RoadIntersection.new(Vector3(2, 0, 1), road_net_info)
	var inter_2 = RoadIntersection.new(Vector3(1, 0, 5), road_net_info)
	var inter_3 = RoadIntersection.new(Vector3(6, 0, 5), road_net_info)
	prints("IDs: ", inter_1.get_id($HTerrain/RoadNetwork.min_vector), inter_2.get_id($HTerrain/RoadNetwork.min_vector))
	var segment = RoadSegmentLinear.new(inter_1, inter_2, road_net_info, RoadSegmentBase.BIDIRECTIONAL)
	var segment1 = RoadSegmentLinear.new(inter_2, inter_3, road_net_info, RoadSegmentBase.BIDIRECTIONAL)
	segment = $HTerrain/RoadNetwork.create_segment(segment)
	segment1 = $HTerrain/RoadNetwork.create_segment(segment1)
	print(segment)
	print(segment1)
	print($HTerrain/RoadNetwork.get_all_segments_from_to(inter_1, inter_2))
	$HTerrain/RoadNetwork.upgrade_segment(segment, road_net_info_1)
	print($HTerrain/RoadNetwork.get_all_segments_from_to(inter_1, inter_2)[0].road_network_info == road_net_info_1)
	draw()
	var query_point = Vector3(2, 0, 1.5)
	var im_geo = $HTerrain/RoadNetwork/ImmediateGeometry	
#	DrawingUtils.draw_empty_circle(im_geo, query_point, 0.25, Color.yellow)
#	DrawingUtils.draw_empty_circle(im_geo, query_point, 1, Color.yellow)
#	DrawingUtils.draw_box_with_aabb(im_geo, inter_1.get_aabb(), Color.tan)
#	DrawingUtils.draw_box_with_aabb(im_geo, inter_2.get_aabb(), Color.tan)
#	DrawingUtils.draw_box_with_aabb(im_geo, $HTerrain/RoadNetwork._get_aabb_to_test(query_point), Color.tan)
	var point = $HTerrain/RoadNetwork.get_closest_point_to(query_point, 1)
#	DrawingUtils.draw_line(im_geo, inter_1.position, inter_2.position, Color.aqua)
#	var segment = $HTerrain/RoadNetwork.get_closest_segment_to()
#	if point:
#		DrawingUtils.draw_box_with_aabb(im_geo, $HTerrain/RoadNetwork._get_aabb_to_test(query_point), Color.red)
#		DrawingUtils.draw_empty_circle(im_geo, query_point, 1, Color.red)
#		DrawingUtils.draw_empty_circle(im_geo, point.position, 0.25, Color.lightcoral)
	var id = 9223372036854775807
			#8590034993793
#	print($HTerrain/RoadNetwork.get_segment(inter_1, inter_2))
	print(stepify(id/1000.0, 0.001))
	print(float(id)/100.0)
#	$HTerrain/RoadNetwork.delete_segment(segment)

func draw():
	var road_net = $HTerrain/RoadNetwork
	var im_geo = $HTerrain/RoadNetwork/ImmediateGeometry
	for road_inter in road_net.graph_inter_map.values():
		DrawingUtils.draw_empty_circle(im_geo, road_inter.position, 0.25)
	for road_seg in road_net.graph_seg_map.values():
		DrawingUtils.draw_line(im_geo, road_seg.start_position.position, road_seg.end_position.position, Color.aqua)

func _notification(what):
	match what:
		NOTIFICATION_EXIT_WORLD:
			clear_segments($HTerrain/RoadNetwork)

func clear_segments(road_net):
	print(road_net.graph_seg_map.values())
	for segment in road_net.graph_seg_map.values():
		road_net.delete_segment(segment)
