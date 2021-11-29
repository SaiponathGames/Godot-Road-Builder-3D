extends Node
class_name BuildingNetwork

export(NodePath) var quadtree_pth
onready var quad_tree = get_node(quadtree_pth) as QuadTreeNode

export(NodePath) var buildings_pth
onready var buildings_node = get_node(buildings_pth) as Spatial

var buildings = []

func get_closest_building(to_position: Vector3, distance: int = 0.5):
	var building: BuildingInstance
	var aabb = _get_aabb_for_query(to_position, distance)
	var query = quad_tree.query(aabb)
	for object in query:
		if to_position.distance_to(object.global_transform.origin) < distance:
			building = object
	return building

func is_buildable(aabb: AABB):
	return !quad_tree.query(aabb)
	

func add_building(transform: Transform, building: BuildingInstance, aabb: AABB = AABB(), transform_aabb = false):
	if buildings.has(building):
		push_error("Building is already present.")
		return
	buildings_node.add_child(building)
	building.global_transform = transform
	if !aabb:
		if transform_aabb:
			aabb = transform.xform(building.get_aabb())
		else:
			aabb = building.get_aabb()
	quad_tree.add_body(building, aabb)
	building.building_network = self
	buildings.append(building)
	

func remove_building(building: BuildingInstance):
	quad_tree.remove_body(building)
	buildings.erase(building)
	building.building_network = null
	buildings_node.remove_child(building)
	building.queue_free()
	

func _get_aabb_for_query(position: Vector3, radius: int = 0.5, height: int = 20) -> AABB:
	var a = position
	var b = a + Vector3.UP * height
	var tmp = Vector3.ONE * radius # Vector3(radius, radius, radius)
	var aabb = AABB(min_vec(a, b) - tmp, max_vec(a, b) + tmp)
	return aabb

func min_vec(a, b):
	return Vector3(min(a.x, b.x), min(a.y, b.y), min(a.z, b.z))

func max_vec(a, b):
	return Vector3(max(a.x, b.x), max(a.y, b.y), max(a.z, b.z))
