tool
extends MeshInstance


# 	surface_tool.add_vertex(Vector3(0, 0, 0))
#	surface_tool.add_vertex(Vector3(1, 0, 0))
#	surface_tool.add_vertex(Vector3(1, 0, 1))
#	surface_tool.add_vertex(Vector3(0, 0, 1))
#	surface_tool.add_vertex(Vector3(0, 1, 0))
#	surface_tool.add_vertex(Vector3(1, 1, 0))
#	surface_tool.add_vertex(Vector3(1, 1, 1))
#	surface_tool.add_vertex(Vector3(0, 1, 1))

func _ready():
	var surface_tool = SurfaceTool.new()
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	surface_tool.add_vertex(Vector3(0, 0, 0))
	surface_tool.add_vertex(Vector3(1, 0, 0))
	surface_tool.add_vertex(Vector3(1, 0, 1))
	surface_tool.add_vertex(Vector3(0, 0, 0))
	
	surface_tool.add_vertex(Vector3(0, 1, 1))
	surface_tool.add_vertex(Vector3(0, 1, 0))
	surface_tool.add_vertex(Vector3(0, 0, 0))
	
	surface_tool.add_vertex(Vector3(0, 0, 1))
	surface_tool.add_vertex(Vector3(0, 1, 0))
	surface_tool.add_vertex(Vector3(1, 1, 0))
	surface_tool.add_vertex(Vector3(1, 1, 1))
	surface_tool.add_vertex(Vector3(0, 1, 1))
	
	surface_tool.add_index(0)
	surface_tool.add_index(1)
	surface_tool.add_index(3)
	surface_tool.add_index(3)
	surface_tool.add_index(1)
	surface_tool.add_index(2)
	
	surface_tool.add_index(3 + 4 * 1)
	surface_tool.add_index(1 + 4 * 1)
	surface_tool.add_index(0 + 4 * 1)
	surface_tool.add_index(3 + 4 * 1)
	surface_tool.add_index(2 + 4 * 1)
	surface_tool.add_index(1 + 4 * 1)
	
	surface_tool.add_index(3 + 4 * 2)
	surface_tool.add_index(1 + 4 * 2)
	surface_tool.add_index(0 + 4 * 2)
	surface_tool.add_index(3 + 4 * 2)
	surface_tool.add_index(2 + 4 * 2)
	surface_tool.add_index(1 + 4 * 2)
	
	surface_tool.add_index(3 + 4 * 3)
	surface_tool.add_index(1 + 4 * 3)
	surface_tool.add_index(0 + 4 * 3)
	surface_tool.add_index(3 + 4 * 3)
	surface_tool.add_index(2 + 4 * 3)
	surface_tool.add_index(1 + 4 * 3)
	
	surface_tool.add_index(3 + 4 * 4)
	surface_tool.add_index(1 + 4 * 4)
	surface_tool.add_index(0 + 4 * 4)
	surface_tool.add_index(3 + 4 * 4)
	surface_tool.add_index(2 + 4 * 4)
	surface_tool.add_index(1 + 4 * 4)
	
	surface_tool.add_index(3 + 4 * 5)
	surface_tool.add_index(1 + 4 * 5)
	surface_tool.add_index(0 + 4 * 5)
	surface_tool.add_index(3 + 4 * 5)
	surface_tool.add_index(2 + 4 * 5)
	surface_tool.add_index(1 + 4 * 5)
	
	surface_tool.commit(mesh)

# 0, 1, 3, 3, 1, 2
# 3, 1, 0, 2, 1, 3
