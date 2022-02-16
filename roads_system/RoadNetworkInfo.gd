extends Resource
class_name RoadNetworkInfo

export var name: String
export var id: String
export var lanes = [] # Array[RoadLaneInfo]
export var intersection_length: float = 1
export var segment_width: float = 0.5
export var intersection_end_radius: float = 0.5
export var intersection_curvature: float = 0.3
export var segment_subdivision_length = 5.0

func _init(_id: String, _name: String, _intersection_length: float, _segment_width: float, _intersection_end_radius: float, _intersection_curvature: float = 0.3, _segment_subdivision_length = 5):
	self.id = _id
	self.name = _name
	self.intersection_length = _intersection_length
	self.segment_width = _segment_width
	self.intersection_end_radius = _intersection_end_radius
	self.intersection_curvature = _intersection_curvature
	self.segment_subdivision_length = _segment_subdivision_length

func add_lane(road_lane_info):
	lanes.append(road_lane_info)

func create_intersection(position: Vector3) -> RoadIntersection:
	return RoadIntersection.new(position, self)
