extends Spatial

const RoadIntersection = RoadNetwork.RoadIntersection
const RoadSegment = RoadNetwork.RoadSegment

var road_network: RoadNetwork

var length = 1
var radius = 1

var intersection_1 = null


func _ready():
	var surface_tool = SurfaceTool.new()
	surface_tool.begin(Mesh.PRIMITIVE_LINES)
	
	road_network = RoadNetwork.new()
	road_network.use_quad_tree = false
	road_network.immediate_geo_node = $ImmediateGeometry.get_path()
	add_child(road_network)
	
	var intersect_1 = RoadIntersection.new(Vector3(2, 0, 3) * 5, [])
	var intersect_2 = RoadIntersection.new(Vector3(6, 0, 5.3) * 3, [])
	var intersect_3 = RoadIntersection.new(Vector3(5, 0, 3) * 3, [])
	var intersect_4 = RoadIntersection.new(Vector3(3, 0, 8) * 3, [])
	var intersect_5 = RoadIntersection.new(Vector3(5, 0, -2) * 3, [])
	var intersect_6 = RoadIntersection.new(Vector3(16.3, 0, 18) * 3, [])

	road_network.add_intersection(intersect_1)
	road_network.add_intersection(intersect_2)
	road_network.add_intersection(intersect_3)
	road_network.add_intersection(intersect_4)
#	road_network.add_intersection(intersect_5)
#	road_network.add_intersection(intersect_6)

	road_network.connect_intersections(intersect_1, intersect_2)
	road_network.connect_intersections(intersect_2, intersect_3)
	road_network.connect_intersections(intersect_1, intersect_4)
#	road_network.connect_intersections(intersect_3, intersect_5)
#	road_network.connect_intersections(intersect_4, intersect_5)
#	road_network.connect_intersections(intersect_5, intersect_6)
#	road_network.connect_intersections(intersect_3, intersect_6)
	
	# sort the angles
	for intersection in road_network.intersections:
		if intersection.connections.size() > 1:
			var _sorter = Sorter.new(self, "sort_by_angle", intersection.connections, [intersection])
#	road_network.draw(Color.white, Color.aqua)
	var vertex_array = {}
	for intersection in road_network.intersections:
		var v1dict = draw_intersection(intersection)
		
		draw_complete_intersection(surface_tool, intersection, v1dict[0], v1dict[1])
#		print(v1dict[0], v1dict[1])
		vertex_array[intersection] = v1dict
	
#	var connection_index = 0
#	print(road_network.network.values().size())
	for connection in road_network.network.values():
		var start_dict = vertex_array[connection.start_position]
		var end_dict = vertex_array[connection.end_position]
		
		var start_connection_intersection = start_dict[0][connection]
		var end_connection_intersection = end_dict[0][connection]
		draw_connection(surface_tool, start_connection_intersection, end_connection_intersection)
	
	$MeshInstance.mesh = surface_tool.commit()

func compute_intersection(p0, angle0, p1, angle1) -> Vector3:
	var midpoint = (p0+p1)/2.0
	var arc = abs(angle0 - angle1)
	var midangle = (angle0 + angle1)/2.0
	# print("angle: ", midangle, ", distance: ", midpoint.distance_to(vert0.v1))
	var offset = Vector3()
	if not is_zero_approx(arc):
		offset = Vector3(sin(midangle), 0, cos(midangle))*midpoint.distance_to(p0)/tan(arc/2)
	else:
		offset = Vector3(sin(midangle), 0, cos(midangle))*midpoint.distance_to(p0)
	# print("offset: ", offset)
	return midpoint - offset


func compute_edge_intersection(vert0, vert1) -> Vector3:
	return compute_intersection(vert0.v1, vert0.angle, vert1.v2, vert1.angle)

func draw_intersection(intersection: RoadIntersection):
	# DrawingUtils.draw_empty_circle($ImmediateGeometry, intersection.position, 0.5, Color.lightcyan)

	var intersection_verts = {}
	var start_points = []
	for connection in intersection.connections:
		if connection.width != 0:
			var vert = {}
			var intersection_bound_for = connection.start_position if intersection == connection.end_position else connection.end_position
			var direction = intersection.direction_to(intersection_bound_for)
			var start_point = intersection.position + direction * length
			start_points.append(start_point)
#			DrawingUtils.draw_empty_circle($ImmediateGeometry, start_point, 0.25, Color.yellow)
			vert["start_position"] = start_point
			var left = Vector3(-direction.z, direction.y, direction.x)
			left = left.normalized()
			var v1 = start_point + left * connection.width * 0.5
			var v2 = start_point + -left * connection.width * 0.5
			vert["v1"] = v1
			vert["v2"] = v2
			vert["angle"] = atan2(direction.x, direction.z)
#			DrawingUtils.draw_empty_circle($ImmediateGeometry, v1, 0.125, Color.red)
#			DrawingUtils.draw_empty_circle($ImmediateGeometry, v2, 0.125, Color.green)
			intersection_verts[connection] = vert

	var connections = intersection.connections
	var mid_points = []
	for connection_idx in connections.size()-1:
		if connections[connection_idx].width != 0:
			var point = compute_edge_intersection(intersection_verts[connections[connection_idx]], intersection_verts[connections[connection_idx+1]])
			DrawingUtils.draw_empty_circle($ImmediateGeometry, point, 0.125, Color.bisque)
			mid_points.append(point)
	var point = compute_edge_intersection(intersection_verts[connections[-1]], intersection_verts[connections[0]])
	DrawingUtils.draw_empty_circle($ImmediateGeometry, point, 0.125, Color.orange)
	mid_points.append(point)
		
	return [intersection_verts, mid_points]

func draw_connection(surface_tool: SurfaceTool, i1: Dictionary, i2: Dictionary):
	draw_triangle(surface_tool,
		i1.v1,
		i2.v1,
		i2.v2,
		Color(0.25, 0.5, 0.25))
	draw_triangle(surface_tool,
		i1.v2,
		i2.v1,
		i1.v1,
		Color(0.75, 0.5, 0.25))

func draw_complete_intersection(surface_tool, intersection, vertex_data, mid_point_data):
	if intersection.connections.size() == 1:
		var v1 = vertex_data[vertex_data.keys()[0]].v1
		var v2 = vertex_data[vertex_data.keys()[0]].v2
		var offset_midpoint =  mid_point_data[0]
		var real_midpoint = (v1 + v2) / 2.0
		var offset = offset_midpoint - real_midpoint
		draw_curve_triangles(surface_tool, v1, v1 + offset, offset_midpoint, real_midpoint, Color.darkorange)
		draw_curve_triangles(surface_tool, offset_midpoint, v2 + offset, v2, real_midpoint, Color.darkorchid)
	else:
		var vertex0 = vertex_data[vertex_data.keys()[0]]
		var midpoint0 = (vertex0.v1 + vertex0.v2) / 2.0
		var vertex1 = vertex_data[vertex_data.keys()[1]]
		var midpoint1 = (vertex1.v1 + vertex1.v2) / 2.0
		
		var road_center_intersection = compute_intersection(midpoint0, vertex0.angle, midpoint1, vertex1.angle)
		var intersection_center = DrawingUtils.quadratic_bezier(midpoint0, road_center_intersection, midpoint1, 0.5)

		var number_of_connections = intersection.connections.size()
		for connection_idx in number_of_connections:
			var color
			match connection_idx:
				0:
					color = Color.green
				1:
					color = Color.orange
				2:
					color = Color.white
				3:
					color = Color.violet
				4:
					color = Color.blue
				5:
					color = Color.orangered
				6:
					color = Color.cyan
				7:
					color = Color.pink
			
			if intersection.connections[connection_idx].width != 0:
				draw_curve_triangles(surface_tool,
					vertex_data[vertex_data.keys()[connection_idx]].v1,
					mid_point_data[connection_idx],
					vertex_data[vertex_data.keys()[(connection_idx+1) % number_of_connections]].v2,
					intersection_center,
					color)
				var p0 = vertex_data[vertex_data.keys()[connection_idx]].v2
				var p1 = vertex_data[vertex_data.keys()[connection_idx]].v1
				draw_triangle(
					surface_tool,
					p0,
					p1,
					intersection_center,
					color
				)

	# DrawingUtils.draw_line($ImmediateGeometry, vertex_data[-1].v1, mid_point_data[-1], Color.red)
	# DrawingUtils.draw_line($ImmediateGeometry, vertex_data[0].v2, mid_point_data[-1], Color.red)

class Sorter:
	var extra_params = []
	var array
	var object: Object
	var function: String
	
	func _init(_object, _function, _array, _extra_params):
		self.object = _object
		self.function = _function
		self.extra_params = _extra_params
		self.array = _array
		self.array.sort_custom(self, "sort")
	
	func get_array():
		return array
	
	func sort(a, b):
		return object.callv(function, [a, b] + extra_params)
		
func sort_by_angle(a, b, origin):
	var a_position = a.start_position.position if a.end_position == origin else a.end_position.position
	var b_position = b.start_position.position if b.end_position == origin else b.end_position.position
	var a_offset = a_position - origin.position
	var b_offset = b_position - origin.position

	var angle_1 = atan2(a_offset.x, a_offset.z)
	var angle_2 = atan2(b_offset.x, b_offset.z)

	if angle_1 > angle_2:
		return true

	return a_offset.length_squared() < b_offset.length_squared()
			

func draw_triangle_with_uv(surface_tool: SurfaceTool, v0: Vector3, uv0: Vector2, v1: Vector3, uv1: Vector2, v2: Vector3, uv2: Vector2, color: Color):
	surface_tool.add_color(color)
	surface_tool.add_uv(uv0)
	surface_tool.add_vertex(v0)
	surface_tool.add_color(color)
	surface_tool.add_uv(uv1)
	surface_tool.add_vertex(v1)
	surface_tool.add_color(color)
	surface_tool.add_uv(uv2)
	surface_tool.add_vertex(v2)

func draw_triangle(surface_tool: SurfaceTool, v0: Vector3, v1: Vector3, v2: Vector3, color: Color):
		draw_triangle_with_uv(surface_tool,
		v0,
		Vector2(v0.x, v0.z),
		v1,
		Vector2(v1.x, v1.z),
		v2,
		Vector2(v2.x, v2.z),
		color
	)

func draw_curve_triangles(surface_tool: SurfaceTool, p0: Vector3, mp: Vector3, p1: Vector3, center: Vector3, color: Color, resolution: int = 10):
	var last_point = p0
	for t in range(resolution+1):
		var new_point = quadratic_bezier(p0, mp, p1, t/float(resolution))
		draw_triangle(surface_tool,
			last_point,
			new_point,
			center,
			color)
		last_point = new_point

func quadratic_bezier(p0: Vector3, p1: Vector3, p2: Vector3, t: float):
	var q0 = p0.linear_interpolate(p1, t)
	var q1 = p1.linear_interpolate(p2, t)
	return q0.linear_interpolate(q1, t)
