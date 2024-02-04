func get_road_network_info() -> RoadNetworkInfo:
	# Create a road net info.
	var net_info = RoadNetworkInfo.new(
		"two_lane_basic_road",
		"Two Lane Basic Road",
		0.6,
		2,
		0.75,
		0.3
	)
	net_info.add_lane(
		RoadLaneInfo.new(
			RoadLaneInfo.Direction.FORWARD,
			1,
			0.5
		)
	)
	net_info.add_lane(
		RoadLaneInfo.new(
			RoadLaneInfo.Direction.BACKWARD,
			1,
			-0.5
		)
	)
	return net_info
