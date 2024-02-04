extends Object
class_name RoadSegmentBase

var start_position: RoadIntersectionNode
var end_position: RoadIntersectionNode
var modder_id: int
var custom_id: int
var seg_type: int setget set_seg_type

var length: float setget , get_road_length
var _length: float = NAN

var road_network
var road_network_info: RoadNetworkInfo

var lanes = [] # Array[RoadLanes]

enum {FORWARD = 1, BACKWARD = 2, BIDIRECTIONAL = 3}
var direction = FORWARD

var visible = true
var renderer = null
var id = 0
var positions = []

var position: Vector3 setget , get_position
enum DirectionFrom {START = 0, END = 1}


func _init(_start_position: RoadIntersection, _end_position: RoadIntersection, _road_network_info: RoadNetworkInfo, _direction = BIDIRECTIONAL):
	self.start_position = _start_position.create_node(self)
	self.end_position = _end_position.create_node(self)
	self.road_network_info = _road_network_info
#	self.length = get_length()
	self.direction = _direction
	instance_lanes()
	positions.append(start_position)
	positions.append(end_position)
	renderer = RoadSegmentBaseRenderer

func set_seg_type(value):
	if range(0, 64).has(value):
		seg_type = value
		return
	push_error("Segment type is too big, range is 0 - 63")
		
func get_position():
#	return Vector3(100, 0, 100)
	var result = Vector3()
	print(positions.empty(), not is_instance_valid(positions), positions)
	if not positions or positions.empty():
		return result
	for _position in positions:
		if is_instance_valid(_position):
			result += _position.position
	return result/positions.size()

func get_road_length():
	if not _length:
		_length = get_length()
	return _length

# Abstract methods (do not delete) (must be implemented)

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

func _average_direction(_road_intersection: RoadIntersection, _position: RoadIntersection):
	pass

func _delete():
	pass
# End of abstract methods

func delete():
	_delete()


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
#	if road_net == null:
#		print("Ignored for now")
#		push_warning("Delete this message ASAP! Debug only!")
#		return
	self.road_network = road_net
	if road_net:
		id = get_id(road_net.min_vector)
	self.start_position.set_owner(road_net)
	self.end_position.set_owner(road_net)
	

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

func distance_to(_position: Vector3):
	var closest_point = project_point(_position)
	return closest_point.distance_to(_position)
	
func distance_squared_to(_position: Vector3):
	var closest_point = project_point(_position)
	return closest_point.distance_squared_to(_position)

func direction_to(_position: Vector3):
	var closest_point = project_point(_position)
	return closest_point.direction_to(_position)

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
	var from_bit_left_shift = 18
	var seg_type_left_shift = 6 + from_bit_left_shift
	var custom_left_shift = 12 + seg_type_left_shift
	var modder_left_shift = 10 + custom_left_shift
	
	var _id = int(
		((modder_id << modder_left_shift)
				| (custom_id << custom_left_shift)
				| (seg_type << seg_type_left_shift)
				| (start_position.intersection.get_id(min_vec) << from_bit_left_shift)
				| (end_position.intersection.get_id(min_vec))
		)
	)
	return _id

func set_renderer(_renderer):
	renderer = _renderer

func _notification(what):
	match what:
		NOTIFICATION_PREDELETE:
			prints("About to be deleted RoadSegmentBase Segment ID:", id)

func _sum_array(arr: Array) -> Vector3:
	var result: Vector3 = Vector3.ZERO
	for value in arr:
		result += value
	return result
