extends Node

class_name CustomSorter

var extra_params = []
var object: Object
var function: String

func _init(_object, _function, _extra_params):
	self.object = _object
	self.function = _function
	self.extra_params = _extra_params

func sort_array(array: Array) -> Array:
	array.sort_custom(self, "_sort")
	return array

func sort_dict(dict: Dictionary, sort_by_value = true) -> Dictionary:
	var sorted_dict = {}
	if sort_by_value:
		var values = dict.values()
		values.sort_custom(self, "_sort")
		for value in values:
			sorted_dict[_find_key(dict, value)] = value
	else:
		var keys = dict.keys()
		keys.sort_custom(self, "_sort")
		for key in keys:
			sorted_dict[key] = dict[key]
	return sorted_dict

func _find_key(dict: Dictionary, value):
	for key in dict:
		if dict[key] == value:
			return key

func _sort(a, b):
	return object.callv(function, [a, b] + extra_params)
