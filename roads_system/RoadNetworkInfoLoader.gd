extends Node

func _ready():
	var files = PathServer.get_dir_contents("res://roads_system/road_net_infos/")[0]
	for file in files:
		file = file as String
		file = file.trim_suffix(".remap")
		if file.ends_with("network_info.gd"):
			var script = load(file).new()
			RoadNetworkInfoRegister.register(script.get_road_network_info())

