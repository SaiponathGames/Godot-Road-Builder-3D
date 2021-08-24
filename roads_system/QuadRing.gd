tool
extends MeshInstance

export var angular_segment = 8 setget set_angular_segments
export var inner_radius = 2 setget set_inner_radius
export var outer_radius = 3 setget set_outer_radius
export(int, 0, 360) var start_angle = 45 setget set_start_angle
export(int, 0, 360) var end_angle = 90 setget set_end_angle
export var rings = 8 setget set_rings
export var filled = true setget set_filled

func set_angular_segments(value):
	angular_segment = value
	_generate()

func set_inner_radius(value):
	inner_radius = value
	_generate()

func set_outer_radius(value):
	outer_radius = value
	_generate()

func set_start_angle(value):
	start_angle = value
	_generate()

func set_end_angle(value):
	end_angle = value
	_generate()

func set_rings(value):
	rings = value
	_generate()

func set_filled(value):
	filled = value
	_generate()

func _generate():
	var surface_tool = SurfaceTool.new()
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	if !filled:
		for i in range(angular_segment+1):
			var t = i / float(angular_segment)
			var angle = deg2rad(start_angle + i * (end_angle-start_angle) / float(angular_segment) - 90)
			var position_inner = Vector3(0, 0, inner_radius)
			var position_outer = Vector3(0, 0, outer_radius)
			surface_tool.add_vertex(position_inner.rotated(Vector3.UP, angle))
			surface_tool.add_vertex(position_outer.rotated(Vector3.UP, angle))
		
		for i in range(angular_segment):
			var root_index = i * 2
			
			surface_tool.add_index(root_index + 0)
			surface_tool.add_index(root_index + 2)
			surface_tool.add_index(root_index + 3)
			
			surface_tool.add_index(root_index + 0)
			surface_tool.add_index(root_index + 3)
			surface_tool.add_index(root_index + 1)
	else:
		surface_tool.add_vertex(global_transform.origin)
		
		for i in range(angular_segment+1):
			var t = i / float(angular_segment)
			var angle = deg2rad(start_angle + i * (end_angle-start_angle) / float(angular_segment) - 90)
			var position_outer = Vector3(0, 0, outer_radius)
			surface_tool.add_vertex(position_outer.rotated(Vector3.UP, angle))
		
		for i in range(angular_segment):
			
			surface_tool.add_index(0)
			surface_tool.add_index(i + 2)
			surface_tool.add_index(i + 1)
			
		
	mesh = ArrayMesh.new()
	surface_tool.commit(mesh)
