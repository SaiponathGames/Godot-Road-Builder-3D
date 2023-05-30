func get_road_network_info() -> RoadNetworkInfo:
	# Create a road net info.
	var net_info = RoadNetworkInfo.new(
		"four_lane_basic_road",
		"Four Lane Basic Road",
		0.5,
		4,
		1.0,
		0.3
	)
	# Add lanes
	net_info.add_lane(
		RoadLaneInfo.new(
			RoadLaneInfo.Direction.FORWARD,
			1,
			1.5
		)
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
	net_info.add_lane(
		RoadLaneInfo.new(
			RoadLaneInfo.Direction.BACKWARD,
			1,
			-1.5
		)
	)
	return net_info
