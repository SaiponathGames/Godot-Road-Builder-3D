extends Spatial
class_name BuildingInstance

var building
var id

func get_aabb():
	var aabb: AABB
	for child in get_children():
		if child is MeshInstance:
			if !aabb:
				aabb = child.get_transformed_aabb()
			else:
				aabb.merge(child.get_transformed_aabb())
	return aabb
