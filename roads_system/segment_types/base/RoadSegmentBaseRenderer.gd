extends Reference
class_name RoadSegmentBaseRenderer

var sidewalk_height = 0.062
var sidewalk_width = 0.5

func render(mesh_drawer: MeshDrawer, segment, debug_immediate_geo: ImmediateGeometry, resolution: int = 5):
	print("Rendering segment", segment)
	var s_v1 = segment.start_position.get_left_vertex()
	var s_v2 = segment.start_position.get_right_vertex()
	
	var e_v1 = segment.end_position.get_left_vertex()
	var e_v2 = segment.end_position.get_right_vertex()
	
	var last_v1 = s_v1
	var last_v2 = s_v2
	
	
	var last_point = (s_v1+s_v2) / 2
	var dir = segment.direction_at(last_point)
	var lal_dir = Vector3(-dir.z, 0, dir.x)
	
	var last_sw_heiPoint = Vector3(s_v1.x, s_v1.y + sidewalk_height, s_v1.z)
	var last_sw_widBase = s_v1 + -lal_dir * sidewalk_width
	var last_sw_widHeiPoint = last_sw_widBase + Vector3.UP * sidewalk_height
	
	var last_v2_sw_heiPoint = Vector3(s_v2.x, s_v2.y + sidewalk_height, s_v2.z)
	var last_v2_sw_widBase = s_v2 + lal_dir * sidewalk_width
	var last_v2_sw_widHeiPoint = last_v2_sw_widBase + Vector3.UP * sidewalk_height
	
	for i in resolution+1:
		var t = i/float(resolution)
		var v1 = segment.get_lerp_func().call_func(s_v1, e_v2, t)
		var v2 = segment.get_lerp_func().call_func(s_v2, e_v1, t)
		
#		DrawingUtils.draw_empty_circle(debug_immediate_geo, v1, 0.125, Color.yellow)
#		DrawingUtils.draw_empty_circle(debug_immediate_geo, v2, 0.125, Color.yellow)
		mesh_drawer.draw_triangle(
			v2,
			v1,
			last_v1)
			
		var point = (v1+v2) / 2
		var direction = segment.direction_at(point)
		var l_dir = Vector3(-direction.z, 0, direction.x)
		
		var sw_heiPoint = Vector3(v1.x, v1.y + sidewalk_height, v1.z)
		var sw_widBase = v1 + -l_dir * sidewalk_width
		var sw_widHeiPoint = sw_widBase + Vector3.UP * sidewalk_height
		
		var v2_sw_heiPoint = Vector3(v2.x, v2.y + sidewalk_height, v2.z)
		var v2_sw_widBase = v2 + l_dir * sidewalk_width
		var v2_sw_widHeiPoint = v2_sw_widBase + Vector3.UP * sidewalk_height

		if i > 0:
			mesh_drawer.draw_triangle(
				v1, sw_heiPoint, last_v2, Color.aqua
			)

			mesh_drawer.draw_triangle(
				last_v2, sw_heiPoint, last_sw_widHeiPoint, Color.red
			)

			mesh_drawer.draw_triangle(
				last_sw_widBase, sw_widHeiPoint, sw_widBase, Color.orange
			)

			mesh_drawer.draw_triangle(
				last_sw_heiPoint, sw_widHeiPoint, last_sw_widBase, Color.purple
			)

			# v2
			mesh_drawer.draw_triangle(
				last_v1, v2_sw_heiPoint, v2, Color.aqua
			)

			mesh_drawer.draw_triangle(
				last_v2_sw_widHeiPoint, v2_sw_heiPoint, last_v1, Color.red
			)
			
			mesh_drawer.draw_triangle(
				v2_sw_widBase, v2_sw_widHeiPoint, last_v2_sw_widBase, Color.orange
			)
			
			mesh_drawer.draw_triangle(
				last_v2_sw_widBase, v2_sw_widHeiPoint, last_v2_sw_heiPoint, Color.purple
			)
		
		mesh_drawer.draw_triangle(
			last_v2_sw_heiPoint, v2_sw_widHeiPoint, last_v2_sw_widHeiPoint, Color.sandybrown
		)

		mesh_drawer.draw_triangle(
			last_v2_sw_widHeiPoint, v2_sw_widHeiPoint, v2_sw_heiPoint, Color.sandybrown
		)
		
		mesh_drawer.draw_triangle(
			sw_heiPoint, sw_widHeiPoint, last_sw_widHeiPoint, Color.sandybrown
		)
		
		mesh_drawer.draw_triangle(
			last_sw_widHeiPoint, sw_widHeiPoint, last_sw_heiPoint, Color.sandybrown
		)

		
#		mesh_drawer.draw_triangle(
#			v1, sw_heiPoint, last_v2
#		)
#		mesh_drawer.draw_triangle(
#			last_v2, last_sw_heiPoint, v1
#		)
		
		DrawingUtils.draw_empty_circle(debug_immediate_geo, v1, 0.125, Color.white)
		DrawingUtils.draw_empty_circle(debug_immediate_geo, sw_heiPoint, 0.125, Color.black)
		DrawingUtils.draw_empty_circle(debug_immediate_geo, sw_widBase, 0.125, Color.white)
		DrawingUtils.draw_empty_circle(debug_immediate_geo, sw_widHeiPoint, 0.125, Color.black)
		
		last_sw_heiPoint = sw_widHeiPoint
		last_sw_widHeiPoint = sw_heiPoint
		last_sw_widBase = sw_widBase
		
		last_v2_sw_heiPoint = v2_sw_widHeiPoint
		last_v2_sw_widHeiPoint = v2_sw_heiPoint
		last_v2_sw_widBase = v2_sw_widBase
		
		mesh_drawer.draw_triangle(
			last_v1,
			v1,
			last_v2)
		
		last_v1 = v2
		last_v2 = v1
		
#	DrawingUtils.draw_empty_circle(debug_immediate_geo, s_v1, 0.125, Color.black)
#	DrawingUtils.draw_empty_circle(debug_immediate_geo, s_v2, 0.125, Color.black)
	
#	DrawingUtils.draw_empty_circle(debug_immediate_geo, e_v1, 0.125, Color.red)
#	DrawingUtils.draw_empty_circle(debug_immediate_geo, e_v2, 0.125, Color.red)
