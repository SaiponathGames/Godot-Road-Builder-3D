extends Node


func get_edge(aabb: AABB, edge: int) -> Array:
	match edge:
		0:
			return [Vector3(aabb.end.x, aabb.position.y, aabb.position.z),
				Vector3(aabb.position.x, aabb.position.y, aabb.position.z)]
		1:
			return [Vector3(aabb.end.x, aabb.position.y, aabb.end.z), 
				Vector3(aabb.end.x, aabb.position.y, aabb.position.z)]
		2:
			return [Vector3(aabb.position.x, aabb.position.y, aabb.end.z),
				Vector3(aabb.end.x, aabb.position.y, aabb.end.z)]
		3:
			return [Vector3(aabb.position.x, aabb.position.y, aabb.position.z), 
				Vector3(aabb.position.x, aabb.position.y, aabb.end.z)]
		4:
			return [Vector3(aabb.position.x, aabb.end.y, aabb.position.z),
				Vector3(aabb.end.x, aabb.end.y, aabb.position.z)]
		5:
			return [Vector3(aabb.end.x, aabb.end.y, aabb.position.z), 
				Vector3(aabb.end.x, aabb.end.y, aabb.end.z)]
		6:
			return [Vector3(aabb.end.x, aabb.end.y, aabb.end.z),
				Vector3(aabb.position.x, aabb.end.y, aabb.end.z)]
		7:
			return [Vector3(aabb.position.x, aabb.end.y, aabb.end.z), 
				Vector3(aabb.position.x, aabb.end.y, aabb.position.z)]
		8:
			return [Vector3(aabb.position.x, aabb.position.y, aabb.end.z),
				Vector3(aabb.position.x, aabb.end.y, aabb.end.z)]
		9:
			return [Vector3(aabb.position.x, aabb.position.y, aabb.position.z), 
				Vector3(aabb.position.x, aabb.end.y, aabb.position.z)]
		10:
			return [Vector3(aabb.end.x, aabb.position.y, aabb.position.z),
				Vector3(aabb.end.x, aabb.end.y, aabb.position.z)]
		11:
			return [Vector3(aabb.end.x, aabb.position.y, aabb.end.z), 
				Vector3(aabb.end.x, aabb.end.y, aabb.end.z)]
				
	return [Vector3(NAN, NAN, NAN), Vector3(NAN, NAN, NAN)]

# https://gamedev.stackexchange.com/questions/162819/how-do-axis-aligned-bounding-boxes-update-with-rotations
func transform_aabb(transform: Transform, aabb: AABB):
	var corners = [
		aabb.position,
		Vector3(aabb.position.x, aabb.position.y, aabb.end.z),
		Vector3(aabb.position.x, aabb.end.y, aabb.position.z),
		Vector3(aabb.end.x, aabb.position.y, aabb.position.z),
		Vector3(aabb.position.x, aabb.end.y, aabb.end.z),
		Vector3(aabb.end.x, aabb.position.y, aabb.end.z),
		Vector3(aabb.end.x, aabb.end.y, aabb.position.z),
		aabb.end,
	]
	
	var vec_min = Vector3.INF
	var vec_max = -Vector3.INF
	
	for corner in corners:
		var transformed = transform.xform(corner)
		vec_min = min_vec(vec_min, transformed)
		vec_max = max_vec(vec_max, transformed)
	
	var new_aabb = AABB(vec_min, Vector3.ONE)
	new_aabb.end = vec_max
	return new_aabb
	

func min_vec(a, b):
	return Vector3(min(a.x, b.x), min(a.y, b.y), min(a.z, b.z))

func max_vec(a, b):
	return Vector3(max(a.x, b.x), max(a.y, b.y), max(a.z, b.z))
