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
	

func add_building(transform: Transform, building: BuildingInstance):
	if buildings.has(building):
		push_error("Building is already present.")
		return
	buildings_node.add_child(building)
	building.global_transform = transform
	quad_tree.add_body(building, building.get_aabb())
	buildings.append(building)
	

func remove_building(building: BuildingInstance):
	quad_tree.remove_body(building)
	buildings.erase(building)
	buildings_node.remove_child(building)
	building.queue_free()
	

func _get_aabb_for_query(position: Vector3, radius: int = 0.5, height: int = 20) -> AABB:
	var mesh_inst = MeshInstance.new()
	var cylinder = CylinderMesh.new()
	cylinder.top_radius = radius
	cylinder.bottom_radius = radius
	cylinder.height = height
	mesh_inst.mesh = cylinder
	var aabb = mesh_inst.get_aabb()
	aabb.position.x += position.x
	aabb.position.y += position.y
	aabb.position.z += position.z
	mesh_inst.free()
	return aabb
