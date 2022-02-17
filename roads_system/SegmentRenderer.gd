extends MeshInstance
class_name SegmentRenderer

func update(road_net: RoadNetwork):
	var mesh_drawer = MeshDrawer.new()
	mesh = ArrayMesh.new()
	for type in RoadNetworkInfoRegister.road_net_infos.values():
		mesh_drawer.begin(Mesh.PRIMITIVE_TRIANGLES)
		for segment in road_net.get_all_segment_of_net_info(type):
			segment = (segment as RoadSegmentBase)
			var renderer = segment.renderer.new()
			renderer.render(mesh_drawer, segment, $ImmediateGeometry)
		mesh_drawer.index()
		mesh = mesh_drawer.commit(mesh)
