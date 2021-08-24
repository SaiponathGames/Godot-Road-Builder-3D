extends MeshInstance


func _ready():
	var arr = []
	arr.resize(ArrayMesh.ARRAY_MAX)
	var vertices = PoolVector3Array([Vector3(0, 0, 0), Vector3(0, 0, 1), Vector3(1, 0, 1), Vector3(1, 0, 0)])
	var indices = PoolIntArray([3, 1, 0, 2, 1, 3])
	var uvs = PoolVector2Array([Vector2(0, 0), Vector2(0, 1), Vector2(1, 1), Vector2(1, 0)])
	arr[ArrayMesh.ARRAY_VERTEX] = vertices
	arr[ArrayMesh.ARRAY_INDEX] = indices
	arr[ArrayMesh.ARRAY_TEX_UV] = uvs
	
	(mesh as ArrayMesh).add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arr)

# 0, 1, 3, 3, 1, 2
