extends Node

export(NodePath) var world_road_network_node
onready var world_road_network: RoadNetwork = get_node(world_road_network_node) as RoadNetwork

export(SpatialMaterial) var buildable_mat
export(SpatialMaterial) var non_buildable_mat

enum States {
	ROAD_TOOL_STRAIGHT,
	ROAD_TOOL_CURVED,
	ROAD_TOOL_FREEFORM,
}

var state = States.ROAD_TOOL_STRAIGHT

var tool_state: Spatial # RoadState

onready var local_road_network = $RoadNetwork

func _ready():
	$States/RoadToolStraight.set_enabled(true)
	$States/RoadToolStraight.local_road_network = local_road_network
	$States/RoadToolStraight.global_road_network = world_road_network
