extends Reference
class_name RoadSegmentBase

var start_position: RoadIntersectionNode
var end_position: RoadIntersectionNode
var modder_id: int
var custom_id: int
var seg_type: int setget set_seg_type

var length: float

var road_network
var road_network_info: RoadNetworkInfo

var lanes = [] # Array[RoadLanes]

enum {FORWARD = 1, BACKWARD = 2, BIDIRECTIONAL = 3}
var direction = FORWARD

var visible = true
var renderer = null
var id = -1
var positions = []

enum DirectionFrom {START = 0, END = 1}


func _init(_start_position: RoadIntersection, _end_position: RoadIntersection, _road_network_info: RoadNetworkInfo, _direction = BIDIRECTIONAL):
	self.start_position = _start_position.create_node(self)
	self.end_position = _end_position.create_node(self)
	self.road_network_info = _road_network_info
	self.length = get_length()
	self.direction = _direction
	instance_lanes()
	positions.append(_start_position)
	positions.append(_end_position)
	renderer = RoadSegmentBaseRenderer

func set_seg_type(value):
	if range(0, 64).has(value):
		seg_type = value
		return
	push_error("Segment type is too big, range is 0 - 63")
		

# Abstract methods (do not delete)

func get_length():
	pass

func get_point(_t):
	pass

func get_lerp_func():
	pass

func project_point(_position: Vector3):
	pass

func get_aabb():
	pass

func _average_direction(road_intersection: RoadIntersection, position: RoadIntersection):
	pass

func _delete():
	pass
# End of abstract methods

func delete():
	_delete()
	start_position.delete_node()
	end_position.delete_node()

func direction_from(from: int):
	match from:
		DirectionFrom.START:
			return _average_direction(start_position.intersection, end_position.intersection)
		DirectionFrom.END:
			return _average_direction(end_position.intersection, start_position.intersection)

func direction_from_intersection(intersection: RoadIntersectionNode):
	match intersection:
		start_position:
			return _average_direction(start_position.intersection, end_position.intersection)
		end_position:
			return _average_direction(end_position.intersection, start_position.intersection)
	
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

# Abstract features, recommend to implement, but can be left unimplemented.

func split_at_position(_position: RoadIntersection): # Array[RoadSegmentBase]
	pass

func subdivide(): # Array[RoadSegmentBase]
	pass

func join_segments(_segments: Array): # segments: Array[RoadSegmentBase] -> RoadSegmentBase
	pass

# End of abstract features.

## Get ID returns a ID of the segment this is being conputed like this:
## 10 bits (modders) + 12 bits (custom) + 6 bits (segment type) + 18 bits (from) + 18 bits (to)
## Warning: Do not override this function, change custom and seg_id and modder_id to generate unique ids.
func get_id(min_vec: Vector3):
	if id != -1:
		return id
	var from_bit_left_shift = 18
	var seg_type_left_shift = 6 + from_bit_left_shift
	var custom_left_shift = 12 + seg_type_left_shift
	var modder_left_shift = 10 + custom_left_shift
	
	id = int(((modder_id << modder_left_shift)
				| (custom_id << custom_left_shift)
				| (seg_type << seg_type_left_shift)
				| (start_position.intersection.get_id(min_vec) << from_bit_left_shift)
				| (end_position.intersection.get_id(min_vec))))
	return id

func set_renderer(_renderer):
	renderer = _renderer
