tool
extends EditorPlugin

var quad_tree = load("res://addons/sairam.quadtree/QuadTreeNode.gd")
var quad_tree_icon = load("res://addons/sairam.quadtree/Tree.svg")
const QuadTreeGizmoPlugin = preload("res://addons/sairam.quadtree/QuadTreeGizmoPlugin.gd")

var quad_tree_gizmo_plugin = QuadTreeGizmoPlugin.new()

func _enter_tree() -> void:
	add_autoload_singleton("AABBUtils", "res://addons/sairam.quadtree/AABBUtils.gd")
	add_autoload_singleton("MetaStaticFuncs", "res://addons/sairam.quadtree/Meta_Static_Funcs.gd")
	add_custom_type("QuadTreeNode", "Spatial", quad_tree, quad_tree_icon)
	add_spatial_gizmo_plugin(quad_tree_gizmo_plugin)
	quad_tree_gizmo_plugin.set_undo_redo(get_undo_redo())


func _exit_tree() -> void:
	remove_spatial_gizmo_plugin(quad_tree_gizmo_plugin)
	remove_custom_type("QuadTreeNode")
	remove_autoload_singleton("MetaStaticFuncs")
	remove_autoload_singleton("AABBUtils")
