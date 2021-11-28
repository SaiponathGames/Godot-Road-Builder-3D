extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	var road_net_info = RoadNetworkInfo.new('test', 'test', 0.4, 0.5, 0.6, 10)
	var road_net_info_1 = RoadNetworkInfo.new('test_1', 'test_1', 0.4, 0.5, 0.6, 10)
	var inter_1 = RoadIntersection.new(Vector3(2, 0, 1), road_net_info)
	var inter_2 = RoadIntersection.new(Vector3(1, 0, 2), road_net_info)
	var segment = $HTerrain/RoadNetwork.create_segment(inter_1, inter_2, road_net_info)
	print(segment)
	print($HTerrain/RoadNetwork.get_segment(inter_1, inter_2))
	$HTerrain/RoadNetwork.upgrade_segment(segment, road_net_info_1)
	print($HTerrain/RoadNetwork.get_segment(inter_1, inter_2).road_network_info == road_net_info_1)
	
	$HTerrain/RoadNetwork.delete_segment(segment)
#	print($HTerrain/RoadNetwork.get_segment(inter_1, inter_2))
