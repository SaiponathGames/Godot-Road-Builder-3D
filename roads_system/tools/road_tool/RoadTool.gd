extends Node

export(NodePath) var world_road_network_node
onready var world_road_network: RoadNetwork = get_node(world_road_network_node) as RoadNetwork

export(SpatialMaterial) var buildable_mat
export(SpatialMaterial) var non_buildable_mat

enum States {
	ROAD_TOOL_STRAIGHT,
	ROAD_TOOL_CURVED,
	ROAD_TOOL_FREEFORM,
	ROAD_TOOL_BUILDOZE,
	ROAD_TOOL_UPGRADE
}

var state = States.ROAD_TOOL_STRAIGHT
var _enabled

var tool_state: Spatial # RoadState

onready var local_road_network = $LocalRoadNetwork

var road_net_infos = []

func _ready():
	$States/RoadToolStraight.set_enabled(false)
	$States/RoadToolStraight.local_road_network = local_road_network
	$States/RoadToolStraight.global_road_network = world_road_network
	
	
	$States/RoadToolCurved.set_enabled(false)
	$States/RoadToolCurved.local_road_network = local_road_network
	$States/RoadToolCurved.global_road_network = world_road_network
	
	$LocalRoadNetwork/Renderer/SegmentRenderer.material_override = buildable_mat # HACK
	$LocalRoadNetwork/Renderer/IntersectionRenderer.material_override = buildable_mat # HACK
	$States/RoadToolStraight/RoadMesh.material_override = buildable_mat # HACK
	$States/RoadToolStraight/RoadMesh.hide()
	
	road_net_infos = RoadNetworkInfoRegister.list()

func _unhandled_key_input(event):
	if event.scancode == KEY_KP_ADD and event.pressed:
		_enabled = !_enabled
		return
	if !_enabled:
		return
	
	if event.scancode == KEY_KP_1 and event.pressed:
		$States/RoadToolStraight.set_enabled(!$States/RoadToolStraight._enabled)
		$States/RoadToolCurved.set_enabled(false)
	if event.scancode == KEY_KP_2 and event.pressed:
		$States/RoadToolCurved.set_enabled(!$States/RoadToolCurved._enabled)
		$States/RoadToolStraight.set_enabled(false)
	
	if event.scancode == KEY_1 and event.pressed:
		$States/RoadToolCurved.road_net_info = road_net_infos[0]
		$States/RoadToolStraight.road_net_info = road_net_infos[0]
	
	if event.scancode == KEY_2 and event.pressed:
		$States/RoadToolCurved.road_net_info = road_net_infos[1]
		$States/RoadToolStraight.road_net_info = road_net_infos[1]
	
