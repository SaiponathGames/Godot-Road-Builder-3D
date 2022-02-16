extends Reference
class_name RoadLane
	
var lane_info # RoadLaneInfo
var segment # RoadSegmentBase


var start_point: RoadIntersectionNode
var end_point: RoadIntersectionNode

var road_network

func _init(_lane_info, _segment):
	self.segment = _segment
	self.start_point = _segment.start_position
	self.end_point = _segment.end_position
	self.road_network = _segment.road_network
	self.lane_info = _lane_info
