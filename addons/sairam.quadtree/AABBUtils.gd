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
