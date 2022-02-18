extends Node


var road_net_infos: Dictionary

func register(road_net_info: RoadNetworkInfo):
	road_net_infos[road_net_info.id] = road_net_info

func unregister(net_info_name: String):
# warning-ignore:return_value_discarded
	road_net_infos.erase(net_info_name)

func get(net_info_name: String):
	return road_net_infos.get(net_info_name)

func find(mask: String):
	var matching_array = []
	for road_net_info in road_net_infos.values():
		if road_net_info.id.match(mask):
			matching_array.append(road_net_info)
	return matching_array
