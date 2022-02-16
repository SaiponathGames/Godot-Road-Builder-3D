extends Resource
class_name RoadLaneInfo

enum Direction {
	FORWARD = 1,
	BACKWARD = 2,
	BIDIRECTIONAL = 1 | 2
}

export var direction: int = Direction.FORWARD
export var width: float
export var offset: float

func _init(_direction, _width, _offset):
	self.direction = _direction
	self.width = _width
	self.offset = _offset

func instance(_segment):
	return RoadLane.new(self, _segment)
