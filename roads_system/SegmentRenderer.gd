extends MeshInstance
class_name SegmentRenderer

func update(road_net: RoadNetwork):
	var mesh_drawer = MeshDrawer.new()
	mesh_drawer.begin(Mesh.PRIMITIVE_TRIANGLES)
	for segment in road_net.get_all_segments():
		segment = (segment as RoadSegmentBase)
		var renderer = segment.renderer.new()
		renderer.render(mesh_drawer, segment, $"../../ImmediateGeometry")
	mesh = mesh_drawer.commit()

func _on_RoadNetwork_graph_changed(road_net: RoadNetwork):
	update(road_net)

func _input(event):
	if event is InputEventKey:
		if event.scancode == KEY_KP_1 and event.pressed:
			update($"../..") # debug only
