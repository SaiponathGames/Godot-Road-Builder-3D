extends MeshInstance


func update(road_net: RoadNetwork):
	var mesh_drawer = MeshDrawer.new()
	$ImmediateGeometry.clear()
	mesh = ArrayMesh.new()
	mesh_drawer.begin(Mesh.PRIMITIVE_TRIANGLES)
	for intersection in road_net.get_all_intersections():
#		print_debug(intersection)
		intersection = intersection as RoadIntersection
		var renderer = intersection.renderer.new()
		renderer.render(mesh_drawer, intersection, $ImmediateGeometry)
	mesh_drawer.index()
	mesh = mesh_drawer.commit(mesh)
