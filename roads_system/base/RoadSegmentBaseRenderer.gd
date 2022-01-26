extends Node
class_name RoadSegmentBaseRenderer


func render(mesh_drawer: MeshDrawer, segment, debug_immediate_geo: ImmediateGeometry, resolution: int = 5):
	print("Rendering segment", segment)
	var s_v1 = segment.start_position.get_left_vertex()
	var s_v2 = segment.start_position.get_right_vertex()
	
	var e_v1 = segment.end_position.get_left_vertex()
	var e_v2 = segment.end_position.get_right_vertex()
	
	var last_v1 = s_v1
	var last_v2 = s_v2
	for i in resolution+1:
		var t = i/float(resolution)
		var v1 = segment.get_lerp_func().call_func(s_v1, e_v2, t)
		var v2 = segment.get_lerp_func().call_func(s_v2, e_v1, t)
		DrawingUtils.draw_empty_circle(debug_immediate_geo, v1, 0.125, Color.yellow)
		DrawingUtils.draw_empty_circle(debug_immediate_geo, v2, 0.125, Color.yellow)
		mesh_drawer.draw_triangle(
			v2,
			v1,
			last_v1)
		mesh_drawer.draw_triangle(
			last_v1,
			v1,
			last_v2)
		last_v1 = v2
		last_v2 = v1
		
	DrawingUtils.draw_empty_circle(debug_immediate_geo, s_v1, 0.125, Color.black)
	DrawingUtils.draw_empty_circle(debug_immediate_geo, s_v2, 0.125, Color.black)
	
	DrawingUtils.draw_empty_circle(debug_immediate_geo, e_v1, 0.125, Color.red)
	DrawingUtils.draw_empty_circle(debug_immediate_geo, e_v2, 0.125, Color.red)
