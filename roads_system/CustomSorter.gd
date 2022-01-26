extends Node

class_name CustomSorter

var extra_params = []
var object: Object
var function: String

func _init(_object, _function, _extra_params):
	self.object = _object
	self.function = _function
	self.extra_params = _extra_params

func sort(array: Array) -> Array:
	array.sort_custom(self, "_sort")
	return array

func _sort(a, b):
	return object.callv(function, [a, b] + extra_params)
