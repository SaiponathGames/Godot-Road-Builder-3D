extends RoadNetwork


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	var new_intersection = RoadIntersection.new(Vector3(0, 0, 1))
	var new_intersection_1 = RoadIntersection.new(Vector3(0, 0, 3))
	
	var new_segment: RoadSegment = connect_intersections(new_intersection, new_intersection_1)
	
	var points = new_segment.get_points(0.5, 1)
	
	var arr = []
	arr.resize(ArrayMesh.ARRAY_MAX)
	
	calculate_road_mesh_vertices(points, arr, 0.5)


# [Vector3(0, 0, 0), Vector3(0, 0, 1), Vector3(1, 0, 1), Vector3(1, 0, 0)]
# [3, 1, 0, 2, 1, 3]
# [Vector2(0, 0), Vector2(0, 1), Vector2(1, 1), Vector2(1, 0)]

func calculate_road_mesh_vertices(points, arr, road_width = 10, uv_scale = 5.5, use_ping_pong_v = true):
	var vertices = PoolVector3Array()
	vertices.resize(points.size() * 2)
	var indices = PoolIntArray()
	indices.resize(2 * (points.size() - 1) * 3)
	var uvs = PoolVector2Array()
	uvs.resize(vertices.size())
	
	uv_scale = uv_scale * points.size() * 0.05
	var vertex_index = 0
	var triangle_index = 0
	var completion_percentage = 0
	
	for i in points.size():
		var forward = Vector3.ZERO
		if i < points.size() - 1:
#			print("issue", "forward")
			forward += points[i+1] - points[i]
		if i > 0:
#			print("issue", "backward")
			forward += points[i] - points[i-1]
		forward = forward.normalized()
		completion_percentage = i / float(points.size() - 1)
		var v
		if use_ping_pong_v:
			v = 1 - abs(2 * completion_percentage - 1)
		else:
			v = completion_percentage
		uvs[vertex_index] = Vector2(v * uv_scale, -0.1)
		uvs[vertex_index+1] = Vector2(v * uv_scale, 1.1)
		
		var left = Vector3(-forward.z, forward.y, forward.x)
		
		vertices[vertex_index] = points[i] + left * road_width * 0.5
		vertices[vertex_index+1] = points[i] + -left * road_width * 0.5
		
		if i < points.size() - 1:
			indices[triangle_index+0] = vertex_index + 0
			indices[triangle_index+1] = vertex_index + 1
			indices[triangle_index+2] = vertex_index + 2
			
			indices[triangle_index+3] = vertex_index + 1
			indices[triangle_index+4] = vertex_index + 3
			indices[triangle_index+5] = vertex_index + 2
		vertex_index += 2
		triangle_index += 6
	
	arr[ArrayMesh.ARRAY_VERTEX] = vertices
	arr[ArrayMesh.ARRAY_INDEX] = indices
	arr[ArrayMesh.ARRAY_TEX_UV] = uvs
	
	var mesh = ArrayMesh.new()
	
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arr)
	
	$MeshInstance.mesh = mesh
