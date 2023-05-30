extends Resource

var bounds: AABB
var rotation: Basis = Basis.IDENTITY

var grid = []
var im_geo

func _init(_bounds: AABB):
	bounds = _bounds
	grid = []
	for i in range(bounds.size.x):
		grid.append([])
		for _j in range(bounds.size.z):
			grid[i].append(null)

func add_all_item(from_vec: Vector3, to_vec: Vector3, item):
	if not (bounds.has_point(from_vec) and bounds.has_point(to_vec)):
		return
	for i in range(from_vec.x, to_vec.x):
		for j in range(from_vec.z, to_vec.z):
			grid[i][j] = item
		

func add_item(pos: Vector3, item):
	if bounds.has_point(pos):
		grid[pos.x][pos.z] = item

func remove_item(pos: Vector3):
	if bounds.has_point(pos):
		grid[pos.x][pos.z] = null

func update_item(pos: Vector3, item):
	if bounds.has_point(pos):
		grid[pos.x][pos.y] = item

func update_all_item(from_vec: Vector3, to_vec: Vector3, item):
	if not (bounds.has_point(from_vec) and bounds.has_point(to_vec)):
		return
	for i in range(from_vec.x, to_vec.x):
		for j in range(from_vec.z, to_vec.z):
			grid[i][j] = item

func remove_all_item(from_vec: Vector3, to_vec: Vector3):
	if not (bounds.has_point(from_vec) and bounds.has_point(to_vec)):
		return
	for i in range(from_vec.x, to_vec.x):
		for j in range(from_vec.z, to_vec.z):
			grid[i][j] = null

func set_drawing_node(drawing_node: ImmediateGeometry):
	im_geo = drawing_node

func draw(height: float = 1.0):
	var x_pos = bounds.position.x
	var z_pos = bounds.position.z
	var x_end = bounds.end.x
	var z_end = bounds.end.z
	
	var center = bounds.get_center()
	var local_x_pos = x_pos-center.x
	var local_z_pos = z_pos-center.z
	var local_x_end = x_end-center.x
	var local_z_end = z_end-center.z
	
	var Apoint = rotation.xform(Vector3(local_x_pos, height, local_z_pos))+center
	var Bpoint = rotation.xform(Vector3(local_x_end, height, local_z_pos))+center
	var Cpoint = rotation.xform(Vector3(local_x_end, height, local_z_end))+center
	var Dpoint = rotation.xform(Vector3(local_x_pos, height, local_z_end))+center
	
	print(Apoint, Bpoint)
	
	DrawingUtils.draw_empty_circle(im_geo, Apoint, 0.125, Color.black)
	DrawingUtils.draw_empty_circle(im_geo, Bpoint, 0.125, Color.black)
	DrawingUtils.draw_empty_circle(im_geo, Cpoint, 0.125, Color.black)
	DrawingUtils.draw_empty_circle(im_geo, Dpoint, 0.125, Color.black)
	
	DrawingUtils.draw_line(im_geo, Apoint, Bpoint)
	DrawingUtils.draw_line(im_geo, Bpoint, Cpoint)
	DrawingUtils.draw_line(im_geo, Cpoint, Dpoint)
	DrawingUtils.draw_line(im_geo, Dpoint, Apoint)
	
	print("DRAWING LINES")
