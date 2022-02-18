extends Spatial

onready var road_net = get_parent()

func _ready():
	road_net.connect("graph_changed", self, "_on_RoadNetwork_graph_changed")

func _input(event):
	if event is InputEventKey:
		if event.scancode == KEY_KP_1 and event.pressed:
			update(road_net)

func update(_road_net):
	$IntersectionRenderer.update(_road_net) # debug only
	$SegmentRenderer.update(_road_net) # debug only

func _on_RoadNetwork_graph_changed(_road_net: RoadNetwork):
	if is_inside_tree():
		yield(get_tree(), "idle_frame")
		update(_road_net)
