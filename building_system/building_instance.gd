extends Spatial
class_name BuildingInstance

var building
var id

var _mesh_child_index_array = []
var _collision_child_index_array = []

func get_aabb():
	var aabb: AABB
	for child in get_child(0).get_children():
		if child is MeshInstance:
			if !aabb:
				aabb = child.get_transformed_aabb()
			else:
				aabb = aabb.merge(child.get_transformed_aabb())
	return aabb

func _ready():
	for child in get_child(0).get_children():
		if child is MeshInstance:
			_mesh_child_index_array.append(child.get_index())
		elif child is CollisionShape:
			_collision_child_index_array.append(child.get_index())
