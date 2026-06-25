extends Spatial
export var building_net_np: NodePath
export var road_network_np: NodePath
onready var building_net: BuildingNetwork = get_node_or_null(building_net_np) as BuildingNetwork
onready var road_network: RoadNetwork = get_node_or_null(road_network_np) as RoadNetwork

var building_1 = BuildingType.new("test_id", "Test Name", load("res://models/house1/building1.tscn"), 2.2)
var building_2 = BuildingType.new("test_id2", "Test Name 2", load("res://models/house2/house2.tscn"), 2)

var buildings = [building_1, building_1, building_2]

var disabled = true

var seen_segs = []

func _ready():
	building_1.face_direction = Vector3(1, 0, 0)
	building_2.face_direction = Vector3.BACK

func _on_Timer_timeout():
	if disabled:
		return
	print("Trying to place a building")
	var segs = sample_random(road_network.get_all_segments(), max(3, randi() % 25))
	var prev_segs = {}
	for seg in segs:
		if seg in seen_segs:
			if randi() % 100 == 0:
				seen_segs.erase(seg)
			continue
		#if seg is RoadSegmentBezier:
		#	continue
		var rand_point = randf()
		var closest_point = (seg).get_point(rand_point)
		var point_2 = seg.get_point(rand_point+0.01)
		var point_3 = seg.get_point(rand_point-0.01)
		var dir = (point_2 - closest_point + closest_point - point_3).normalized()


		var l_dir = Vector3(-dir.z, dir.y, dir.x)

		var lr_dir = l_dir if randi() % 2 == 0 else -l_dir
#		print(seg)
#		DrawingUtils.draw_line($ImmediateGeometry, closest_point, lr_dir * 2 + closest_point)

		var building = sample_random(buildings)[0]

		var point: Vector3 = closest_point + lr_dir * -((seg.road_network_info.segment_width + building.width)/2)


		var building_transform = calculate_transform(point, closest_point, building)
		var inst = building_net.try_place_building(building, building_transform)
		if inst:
			print(inst)
			DrawingUtils.draw_empty_circle($ImmediateGeometry, point)
			DrawingUtils.draw_line($ImmediateGeometry, point, closest_point)
		if prev_segs.has(seg):
			prev_segs[seg] += int(!is_instance_valid(inst))
		else:
			prev_segs[seg] = int(!is_instance_valid(inst))
	for prev_seg in prev_segs:
		if prev_segs[prev_seg] >= 8:
			print("Failed 8 tries.", prev_seg)
			seen_segs.append(prev_seg)

func calculate_transform(point, closest_point, selected_building):
	var new_building_transform = Transform.IDENTITY
	new_building_transform.origin = point
	
	var a = closest_point - point
	var b = selected_building.face_direction
	var angle_a = atan2(a.z, a.x)
	var angle_b = atan2(b.z, b.x)
	var angle = angle_b - angle_a
	
	new_building_transform.basis = new_building_transform.basis.rotated(Vector3.UP, angle)
	new_building_transform.origin.y += 0.02
#	var b_scale = selected_building.transform.basis.get_scale()
#	new_building_transform.basis = new_building_transform.basis.scaled(b_scale)
	return new_building_transform


static func sample_random(data: Array, size=1):
	var res = []
	if data.size() <= 0:
		return []
	for _i in size:
		data.shuffle()
		res.append(data[randi() % data.size()])
	return res


func _on_GlobalRoadNetwork_road_segment_created(seg: RoadSegmentBase):
	if disabled and true:
		return
	var length = seg.get_length()
	var building = building_1
	var count = int(length / (building.width + 1))
	print('------------------------------')
	print(count)
	
	for i in range(count):
		var _point = float(i)/count
		print(i, _point)
		var closest_point = (seg).get_point(_point)
		var point_2 = seg.get_point(_point+0.01)
		var point_3 = seg.get_point(_point-0.01)
		var dir = (point_2 - closest_point + closest_point - point_3).normalized()
		
		
		var l_dir = Vector3(-dir.z, dir.y, dir.x)
		
		var lr_dir = l_dir 

		var point: Vector3 = closest_point + lr_dir * -((seg.road_network_info.segment_width + building.width)/2)

		var building_transform = calculate_transform(point, closest_point, building)
		var inst = building_net.try_place_building(building, building_transform)
		if inst:
			print(inst)
			DrawingUtils.draw_empty_circle($ImmediateGeometry, closest_point)
			DrawingUtils.draw_line($ImmediateGeometry, point, closest_point)
		
		lr_dir = -l_dir

		point = closest_point + lr_dir * -((seg.road_network_info.segment_width + building.width)/2)
		

		building_transform = calculate_transform(point, closest_point, building)
		inst = building_net.try_place_building(building, building_transform)
		if inst:
			print(inst)
			DrawingUtils.draw_empty_circle($ImmediateGeometry, closest_point)
			DrawingUtils.draw_line($ImmediateGeometry, point, closest_point)

		
	print('---------------------------')
	
