extends Node
static func get_meta_or_null(object: Object, meta_string: String):
	if object.has_meta(meta_string):
		return object.get_meta(meta_string)
	else:
		return null
	

static func remove_meta_with_check(object: Object, meta_string: String) -> void:
	if object.has_meta(meta_string):
		object.remove_meta(meta_string)
		
