extends Node


export(NodePath) var quadtree_pth
onready var quad_tree = get_node(quadtree_pth) as QuadTreeNode

func get_closest_building(to_position: Vector3, distance: int = 0.5):
	pass

func add_building(transform: Transform, building: BuildingInstance):
	pass

func remove_building(building: BuildingInstance):
	pass

func _get_aabb_for_query(position: Vector3, radius: int = 10, height: int = 20) -> AABB:
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
