extends Reference
class_name RoadSegmentBase

var start_position: RoadIntersection
var end_position: RoadIntersection

var length: float

var road_network
var road_network_info: RoadNetworkInfo

var lanes = [] # Array[RoadLanes]

enum {FORWARD = 1, BACKWARD = 2, BIDIRECTIONAL = 3}
var direction = FORWARD

var visible = true

func _init(_start_position: RoadIntersection, _end_position: RoadIntersection, _road_network_info: RoadNetworkInfo, _direction = BIDIRECTIONAL):
	self.start_position = _start_position
	self.end_position = _end_position
	self.road_network_info = _road_network_info
	self.length = get_length()
	self.direction = _direction
	instance_lanes()

# Abstract methods (do not delete)

func get_length():
	pass

# warning-ignore:unused_argument
func get_point(t):
	pass

# warning-ignore:unused_argument
func project_point(position: Vector3):
	pass

func get_aabb():
	pass

# End of abstract methods
	
func instance_lanes():
	for lane in self.road_network_info.lanes:
		lanes.append(lane.instance(self))

func set_owner(road_net):
	self.road_network = road_net

func get_points(spacing, resolution):
	var points = [start_position.position]
	var previous_point = start_position.position
	var distance_since_last_point = 0
	var division_amount = length * resolution * 10
	var time = 0
	while time <= 1:
		time += 1/division_amount
		var point = get_point(time)
		distance_since_last_point += point.distance_to(previous_point)
		while distance_since_last_point >= spacing:
			var over_shoot_distance = distance_since_last_point - spacing
			var new_point = point + (previous_point - point).normalized() * over_shoot_distance
			points.append(new_point)
			distance_since_last_point = over_shoot_distance
			previous_point = new_point
		previous_point = point
	return points

func distance_to(position: Vector3):
	var closest_point = project_point(position)
	return closest_point.distance_to(position)
	
func distance_squared_to(position: Vector3):
	var closest_point = project_point(position)
	return closest_point.distance_squared_to(position)

func direction_to(position: Vector3):
	var closest_point = project_point(position)
	return closest_point.direction_to(position)

