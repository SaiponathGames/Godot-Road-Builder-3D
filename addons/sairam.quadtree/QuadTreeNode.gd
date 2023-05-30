extends Spatial
class_name QuadTreeNode
const QuadTree = preload("res://addons/sairam.quadtree/QuadTree.gd")


export var extents: Vector3 setget set_bounds
export var debug_bounds: AABB setget set_aabb
export var capacity: int
export var max_levels: int
export var draw_quadtree: bool

var bounds: AABB

export(NodePath) var immediate_geo_node_path
var immediate_geo_node: ImmediateGeometry

var _quad_tree: QuadTree

func _ready():
	_quad_tree = QuadTree.new(debug_bounds, capacity, max_levels)
	if immediate_geo_node_path:
		immediate_geo_node = get_node(immediate_geo_node_path)
		_quad_tree.set_drawing_node(immediate_geo_node)

func add_body(body: Spatial, bounds: AABB = AABB()):
	return _quad_tree.add_body(body, bounds)

func remove_body(body: Spatial):
	return _quad_tree.remove_body(body)

func update_body(body: Spatial, bounds: AABB = AABB()):
	return _quad_tree.update_body(body, bounds)

func clear():
	return _quad_tree.clear()

func dump(file_name: String, indent='\t'):
	_quad_tree.dump(file_name, indent)

func query(bounds: AABB):
	return _quad_tree.query(bounds)

func draw(height: float = 1, clear_drawing: bool = true, draw_outlines: bool = true, draw_tree_bounds: bool = true):
	return _quad_tree.draw(height, clear_drawing, draw_outlines, draw_tree_bounds)

func set_bounds(value):
	extents = value
	bounds = AABB(-extents, extents * 2)
	update_gizmo()
	if _quad_tree:
		_quad_tree._bounds = bounds

func set_aabb(value):
	debug_bounds = value
	if _quad_tree:
		_quad_tree._bounds = debug_bounds
	update_gizmo()

func set_extents(value):
	set_bounds(value)

func _process(delta):
	if draw_quadtree:
		draw()

func _unhandled_key_input(event):
	if event.scancode == KEY_KP_8 and event.pressed:
		draw_quadtree = !draw_quadtree
		immediate_geo_node.visible = !immediate_geo_node.visible

#func _exit_tree():
#	_quad_tree.clear()
