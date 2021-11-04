extends Spatial
class_name BuildingInstance

var building
var id

var _mesh_child_index_array = []
var _collision_child_index_array = []

# thanks to Einlander
func _get_aabb_tree(node: Node):
	var final_aabb:AABB
	if (node is VisualInstance) and !(node is ImmediateGeometry):
		var local_aabb:AABB = node.get_transformed_aabb()
		if !local_aabb.has_no_area():
			final_aabb = node.get_transformed_aabb()
	if node.get_child_count() > 0:
		var children = node.get_children()
		for child in children:
			var temp_aabb = _get_aabb_tree(child)
			if !temp_aabb.has_no_area():
				if final_aabb.has_no_area():
					final_aabb = temp_aabb
				else:
					final_aabb = final_aabb.merge(temp_aabb)
	return final_aabb

func get_aabb():
	return _get_aabb_tree(self)

func _ready():
	for child in get_child(0).get_children():
		if child is MeshInstance:
			_mesh_child_index_array.append(child.get_index())
		elif child is CollisionShape:
			_collision_child_index_array.append(child.get_index())
