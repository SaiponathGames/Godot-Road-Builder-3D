extends Node

var _text: String

func get_text_for_ui():
	return _text.trim_suffix("\n")

func _physics_process(delta):
	_text = ""

func add_text(string: String):
	_text += string + "\n"


