extends Control

export(NodePath) var text_label_np
var text_label: Label

func _ready():
	if text_label_np:
		text_label = get_node_or_null(text_label_np)

func _process(delta):
	text_label.text = DebugConsole.get_text_for_ui()
