extends Spatial
class_name BuildingNetwork

export var quad_tree_node_path: NodePath
export var buildings_path: NodePath

signal buildings_changed

signal building_added
signal building_removed

export var min_vector = Vector3(-128, -64, -128)

var quadtree_node: QuadTreeNode
var buildings_node: Spatial

var building_id_map: Dictionary

func _ready():
	if quad_tree_node_path:
		quadtree_node = get_node(quad_tree_node_path)
	if buildings_path:
		buildings_node = get_node(buildings_path)
		
func create_building(building_type: BuildingType, transform_matrix: Transform):
	var building = building_type.instance_at(transform_matrix)
	var building_id = building.get_id()
	building_id_map[building_id] = building
	
	var building_aabb = building.get_aabb()
	var qt_node = Spatial.new()
	qt_node.name = "QuadTree - Building %s" % building.position
	qt_node.set_meta('_building_inst', building)
	qt_node.set_meta('_aabb', building_aabb)
	quadtree_node.add_body(qt_node)
	building.set_meta("_qt_build", qt_node)
	emit_signal("building_added", building)
	return building

func delete_building(building: BuildingInstance):
	var building_id = building.get_id(min_vector)
	building_id_map.erase(building_id)
	
	var qt_node = building.get_meta('_qt_build')
	quadtree_node.remove_body(qt_node)
