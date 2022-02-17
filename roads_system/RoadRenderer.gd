extends Spatial

onready var road_net = get_parent()

func _ready():
	road_net.connect("graph_changed", self, "_on_RoadNetwork_graph_changed")

func _input(event):
	if event is InputEventKey:
		if event.scancode == KEY_KP_1 and event.pressed:
			update($"/..")

func update(road_net):
	$IntersectionRenderer.update(road_net) # debug only
	$SegmentRenderer.update(road_net) # debug only

func _on_RoadNetwork_graph_changed(road_net: RoadNetwork):
	if is_inside_tree():
		yield(get_tree(), "idle_frame")
		update(road_net)
