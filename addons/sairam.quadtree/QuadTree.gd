extends Resource

var _bounds: AABB
var _capacity: int
var _max_level: int
var _level: int
var _parent = null
var _children = []
var _objects = []
var _is_leaf: bool = true
var _center: Vector3
var _immediate_geo_node: ImmediateGeometry

func _init(bounds, capacity, max_level, level = 0, parent = null, immediate_geo_node = null) -> void:
	self._bounds = bounds
	self._capacity = capacity
	self._max_level = max_level 
	self._level = level
	self._parent = parent
	self._center = self._bounds.size / 2
	self._immediate_geo_node = immediate_geo_node
	_set_as_empty_leaf()

func set_drawing_node(immediate_geo: ImmediateGeometry):
	self._immediate_geo_node = immediate_geo

func _set_as_empty_leaf():
	"""
	:PrivateMeth
	
	Set this node to be a leaf node, with no children.
	"""
	self._children = []
	self._children.resize(4)
	_is_leaf = true

func add_body(body: Spatial, bounds: AABB = AABB()) -> Spatial:
	"""
	Adds a new body into the QuadTree.
	"""
	if body.has_meta("_qt"):
		 push_error("body already in tree") # object already in tree. Invariant satisfied.
	if body.has_meta("_aabb"):
		bounds = body.get_meta("_aabb")
	if body.has_meta("_bounds"):
		bounds = body.get_meta("_bounds")
	if !_is_leaf:
		# add to child if not current obj is leaf.
		var child = _get_child(body.get_transformed_aabb() if body.has_method("get_transformed_aabb") else bounds)
		if child:
			return child.add_body(body, bounds)
	
	# add the object into the tree
	body.set_meta("_qt", self)
	if body is Spatial:
		body.set_meta("_bounds", bounds)
	_objects.push_back(body)

	if _is_leaf and _level < _max_level and _objects.size() >= _capacity:
		_subdivide()

	return body

func remove_body(body: Spatial) -> void:
	"""
	Removes the pre-existing body from the QuadTree
	"""
	# print("remove body %s" % body)

	# get the QuadTreeNode
	var qt_node = MetaStaticFuncs.get_meta_or_null(body, "_qt")
	if qt_node == null: 
		print("no meta")
		push_error("Body not in tree")  # body not in tree
	
	if qt_node != self: # check if is different from the current level
		# print("remove body from child")
		qt_node.remove_body(body)  # call the qt_node's remove method
		return
	
	# remove the `_qt` node because it's no longer in quad tree
	_remove_qt_metadata(body)
	MetaStaticFuncs.remove_meta_with_check(body, "_bounds")
	_objects.erase(body)
	_unsubdivide()


func update_body(body: Spatial, bounds: AABB = AABB()) -> void:
	"""
	Updates the body. A method for moving objects.
	"""
	assert(_parent == null) # do not call this except on the root

	if remove_body(body):
		add_body(body, bounds)

func _subdivide() -> void:
	"""
	:PrivateMeth
	
	Subdivides the quad tree into 4 childs.
	"""
	# subdivide the quadtree into 4 childs and initialize them
	var position
	for i in range(4):
		match i:
			0: 
				position = Vector3(_bounds.position.x + _center.x, _bounds.position.y, _bounds.position.z)
			1: 
				position = Vector3(_bounds.position.x, _bounds.position.y, _bounds.position.z)
			2: 
				position = Vector3(_bounds.position.x, _bounds.position.y, _bounds.position.z + _center.z)
			3: 
				position = Vector3(_bounds.position.x + _center.x, _bounds.position.y, _bounds.position.z + _center.z)
		
		# initialize the node and set the child
		_children[i] = get_script().new(AABB(position, _center), _capacity, _max_level, _level+1, self)
	
	_is_leaf = false # change is_leaf to false, because it has childs now.

	# Move the objects to the new children
	if !_objects.empty():
		var existing_objects = _objects
		_objects = []
		for body in existing_objects:
			_remove_qt_metadata(body)
			if body is Spatial and body.get_meta("_bounds"):
				add_body(body, body.get_meta("_bounds"))
			else:
				add_body(body)

	

func clear() -> void:
	"""
	Clears the QuadTree.
	"""
	# print("clear called")
	# recursively remove all the objects
	if !_objects.empty():
		for object in _objects:
			_remove_qt_metadata(object)
		_objects.clear()

	if !_is_leaf:  # if the self is not leaf
		for child in _children:
			child.clear()  # clear all its children
		_set_as_empty_leaf()

func query(bound: AABB) -> Array:
	"""
	Queries the QuadTree and returns the objects that exists within the bounds passed.
	"""
	# query the QuadTree
	return _query(bound)
	

func _query(bound: AABB) -> Array:
	"""
	:PrivateMeth
	
	Queries the QuadTree and returns the objects that exists within the bounds passed.
	"""
	var found_objects = []
	for object in _objects:
		var transformed_aabb
		if object is Spatial and object.has_meta("_bounds"):
			transformed_aabb = object.get_meta("_bounds")
		else:
			transformed_aabb = object.get_transformed_aabb()
		if bound.intersects(transformed_aabb):  # check if the object in the bounds and it's not bound
			# add the object into found_objects
			found_objects.push_back(object)

	if !_is_leaf:
		for leaf in _children:
			# check if the leaf intersects with the bound
			if leaf._bounds.intersects(bound):
				found_objects += leaf._query(bound)  # query the leaf for the objects
	
	return found_objects

func _can_empty_children():
	"""
	:PrivateMeth
	
	Return whether this node can have its children removed.
	"""
	for child in _children:
		if child == null or !child._is_leaf or !child._objects.empty():
			return false
	return true

func _unsubdivide() -> void:
	"""
	:PrivateMeth
	
	Discards all the leafs and childs with no objects.
	"""
	if !_is_leaf and _can_empty_children():
		_set_as_empty_leaf()

	if (!_objects.empty()):
		#  print("has objects", _objects)
		 return  # skip if objects is not empty
	
	if (!_is_leaf):
		for child in _children:
			if !child._is_leaf or !child._objects.empty():
				# print("right");
				return  # skip if the child is not leaf or if there're objects in the child.
	clear()  # clear the level
	if _parent:
		_parent._unsubdivide()  # unsubdivide the parent if needed.

func _get_child(body_bounds: AABB):
	"""
	:PrivateMeth
	
	Gets the child that incorporates itself in the body_bounds passed.
	"""
	# Use the center of the bounds to determine ownership.
	var center_x = body_bounds.position.x + body_bounds.size.x/2 
	var center_z = body_bounds.position.z + body_bounds.size.z/2 
	var left = center_x < _bounds.position.x + _center.x
	if center_z < _bounds.position.z + _center.z:
		if left:
			return _children[1]  # top left
		else:
			return _children[0]  # top right
	else:
		if left:
			return _children[2]  # bottom left
		else:
			return _children[3]  # bottom right

func _create_rect_lines(drawer, height) -> void:
	"""
	:PrivateMeth
	
	:VersionChanged 1.0.1
	Creates the lines that shows the subdivided quadtree.
	"""
	
	# recursively call _create_rect_lines to create dividing lines.
	for child in _children:
		if child:
			child._create_rect_lines(drawer, height)
	
	# create the points
	var p1 = Vector3(_bounds.position.x, height, _bounds.position.z)
	var p2 = Vector3(p1.x + _bounds.size.x, height, p1.z)
	var p3 = Vector3(p1.x + _bounds.size.x, height, p1.z + _bounds.size.z)
	var p4 = Vector3(p1.x, height, p1.z + _bounds.size.z)

	drawer.add_vertex(p1)
	drawer.add_vertex(p2)

	drawer.add_vertex(p2)
	drawer.add_vertex(p3)

	drawer.add_vertex(p3)
	drawer.add_vertex(p4)

	drawer.add_vertex(p4)
	drawer.add_vertex(p1)

func dump(file_name = null, indent = ""):
	if file_name:
		var dir = Directory.new()
		dir.make_dir_recursive("user://dumps")

		var new_file = File.new()
		print(new_file.open("user://dumps/%s.txt" % file_name, File.WRITE))
		print("worked")
		_dump(new_file , indent)
	else:
		_dump()


func _dump(file_obj: File = null, indent = ""):
	if file_obj:
		file_obj.store_line("%sobjects: %s, isLeaf: %s, parent: %s" % [indent, _objects, _is_leaf, _parent])
		for child in _children:
			file_obj.store_line("%schild: %s" % [indent, child])
			if child != null:
				child._dump(file_obj, indent + "  ")
	else:
		print("%sobjects: %s, isLeaf: %s, parent: %s" % [indent, _objects, _is_leaf, _parent])
		for child in _children:
			print("%schild: %s" % [indent, child])
			if child != null:
				child._dump(file_obj, indent + "  ")

func draw(height: float = 1, clear_drawing: bool = true, draw_outlines: bool = true, draw_tree_bounds: bool = true) -> void:
	"""
		:VersionChanged 1.0.1
	Initializes drawing stuff for you, you can use `_draw` method if you want to have special initialization.
	"""
	var drawer = self._immediate_geo_node
	if clear_drawing:
		drawer.clear()
	drawer.begin(Mesh.PRIMITIVE_LINES)
	if draw_tree_bounds:
		_create_rect_lines(drawer, height)
	if draw_outlines:
		_draw(drawer, height)
	drawer.end()
	
func _draw(drawer: ImmediateGeometry, height: float) -> void:
	"""
	:PrivateMeth
	
	Draws the visuals of QuadTree, tweak it however you want.
	"""
	
	# recursively call _draw to draw objects in different subnodes.
	for child in _children:
		if not _is_leaf:
			child._draw(drawer, height)
	
	# draw the bodies
	for body in _objects:
		var rect: Rect2
		# convert aabb to rect for easier usage
		if body is Spatial and body.has_meta("_bounds"):
			rect = _convert_aabb_to_rect(body.get_meta("_bounds"))
		else:
			rect = _convert_aabb_to_rect(body.get_transformed_aabb())
		# get all 4 points
		var Bpoint = Vector3(rect.end.x, height, rect.position.y)
		var Dpoint = Vector3(rect.position.x, height,  rect.end.y)
		var Apoint = Vector3(rect.position.x, height, rect.position.y)
		var Cpoint = Vector3(rect.end.x, height, rect.end.y)
		
		# add them here
		drawer.add_vertex(Apoint)
		drawer.add_vertex(Bpoint)
		drawer.add_vertex(Bpoint)
		drawer.add_vertex(Cpoint)
		drawer.add_vertex(Cpoint)
		drawer.add_vertex(Dpoint)
		drawer.add_vertex(Dpoint)
		drawer.add_vertex(Apoint)
	
static func _convert_aabb_to_rect(transformed_aabb: AABB) -> Rect2:
	"""
	:StaticMeth
	
	Converts a AABB to Rect2
	"""
	return Rect2(Vector2(transformed_aabb.position.x, transformed_aabb.position.z), Vector2(transformed_aabb.size.x, transformed_aabb.size.z))  # assumed as XZ plane

static func _remove_qt_metadata(body):
	"""
	:StaticMeth

	Remove the qt metadata from the passed body.
	"""
	MetaStaticFuncs.remove_meta_with_check(body, "_qt")

static func _calculate_bounds(extents: Vector3) -> AABB:
	return AABB(-extents/2, extents)
