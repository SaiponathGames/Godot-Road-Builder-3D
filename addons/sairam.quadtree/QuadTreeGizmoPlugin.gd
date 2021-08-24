extends EditorSpatialGizmoPlugin

const QuadTreeNode = preload("res://addons/sairam.quadtree/QuadTreeNode.gd")

var undo_redo: UndoRedo

func get_name():
	return "QuadTree"

func has_gizmo(spatial):
	return spatial is QuadTreeNode

func _init():
	create_material("main", Color.black)
	create_handle_material("handles")

func redraw(gizmo):
	gizmo.clear()

	var spatial: QuadTreeNode = gizmo.get_spatial_node()
	var lines = []
	var handles = []
	var aabb = AABB(-spatial.extents, spatial.extents * 2)
	
	for i in range(12):
		for point in get_edge(aabb, i):
			lines.append(point)
		
	for i in range(3):
		var handle = Vector3()
		handle[i] = spatial.extents[i]
		handles.append(handle)
	
	gizmo.add_lines(lines, get_material("main", gizmo))
	gizmo.add_collision_segments(lines)
	gizmo.add_handles(handles, get_material("handles", gizmo))

func get_edge(aabb: AABB, edge: int) -> Array:
	match edge:
		0:
			return [Vector3(aabb.end.x, aabb.position.y, aabb.position.z),
				Vector3(aabb.position.x, aabb.position.y, aabb.position.z)]
		1:
			return [Vector3(aabb.end.x, aabb.position.y, aabb.end.z), 
				Vector3(aabb.end.x, aabb.position.y, aabb.position.z)]
		2:
			return [Vector3(aabb.position.x, aabb.position.y, aabb.end.z),
				Vector3(aabb.end.x, aabb.position.y, aabb.end.z)]
		3:
			return [Vector3(aabb.position.x, aabb.position.y, aabb.position.z), 
				Vector3(aabb.position.x, aabb.position.y, aabb.end.z)]
		4:
			return [Vector3(aabb.position.x, aabb.end.y, aabb.position.z),
				Vector3(aabb.end.x, aabb.end.y, aabb.position.z)]
		5:
			return [Vector3(aabb.end.x, aabb.end.y, aabb.position.z), 
				Vector3(aabb.end.x, aabb.end.y, aabb.end.z)]
		6:
			return [Vector3(aabb.end.x, aabb.end.y, aabb.end.z),
				Vector3(aabb.position.x, aabb.end.y, aabb.end.z)]
		7:
			return [Vector3(aabb.position.x, aabb.end.y, aabb.end.z), 
				Vector3(aabb.position.x, aabb.end.y, aabb.position.z)]
		8:
			return [Vector3(aabb.position.x, aabb.position.y, aabb.end.z),
				Vector3(aabb.position.x, aabb.end.y, aabb.end.z)]
		9:
			return [Vector3(aabb.position.x, aabb.position.y, aabb.position.z), 
				Vector3(aabb.position.x, aabb.end.y, aabb.position.z)]
		10:
			return [Vector3(aabb.end.x, aabb.position.y, aabb.position.z),
				Vector3(aabb.end.x, aabb.end.y, aabb.position.z)]
		11:
			return [Vector3(aabb.end.x, aabb.position.y, aabb.end.z), 
				Vector3(aabb.end.x, aabb.end.y, aabb.end.z)]
				
	return [Vector3(NAN, NAN, NAN), Vector3(NAN, NAN, NAN)]

func get_handle_name(gizmo, index):
	return 'Extents'

func get_handle_value(gizmo, index):
	return gizmo.get_spatial_node().extents

func set_handle(gizmo, index, camera, point):
	var cs = gizmo.get_spatial_node()
	var gt = cs.get_global_transform()
	var gi = gt.affine_inverse()

	var ray_from = camera.project_ray_origin(point)
	var ray_dir = camera.project_ray_normal(point)
	
	var sg = [gi.xform(ray_from), gi.xform(ray_from + ray_dir * 4096)]
	
	var axis = Vector3()
	axis[index] = 1.0
	var array = Geometry.get_closest_points_between_segments(Vector3(), axis * 4096, sg[0], sg[1])
	var d = array[0][index]
	if (d < 0.001):
		d = 0.001

	var he = cs.extents
	he[index] = d
	cs.extents = he

func set_undo_redo(value: UndoRedo):
	undo_redo = value
	
func commit_handle(gizmo, index, restore, cancel=false):
	if cancel:
		gizmo.get_spatial_node().extents = restore
		return
	
	undo_redo.create_action("Change QuadTreeNode Extents")
	undo_redo.add_do_property(gizmo.get_spatial_node(), "extents", gizmo.get_spatial_node().extents)
	undo_redo.add_undo_property(gizmo.get_spatial_node(), "extents", restore)
	undo_redo.commit_action()
	
	
	
	
