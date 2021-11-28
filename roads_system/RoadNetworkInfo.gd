extends Resource
class_name RoadNetworkInfo

export var name: String
export var id: String
export var lanes = [] # Array[RoadLaneInfo]
export var length: float = 1
export var width: float = 0.5
export var end_radius: float = 0.5
export var curvature: float = 0.3
export var subdivide_length = 5.0

func _init(_id: String, _name: String, _length: float, _width: float, _end_radius: float, _curvature: float = 0.3, _lanes = [], _subdivide_length = 5):
	self.id = _id
	self.name = _name
	self.length = _length
	self.width = _width
	self.end_radius = _end_radius
	self.curvature = _curvature
	self.subdivide_length = _subdivide_length
	self.lanes = _lanes

func create_intersection(position: Vector3) -> RoadIntersection:
	return RoadIntersection.new(position, self)
