extends Spatial

export(NodePath) var building_network_path
onready var building_network = get_node(building_network_path) as BuildingNetwork

export(SpatialMaterial) var selected_mat

var previous_closest_building = null
var enabled
func _input(event):
	if event is InputEventKey:
		if event.scancode == KEY_Y and event.pressed:
			enabled = !enabled
	
	if !enabled:
		return
	
	if event is InputEventMouseMotion:
		if previous_closest_building and is_instance_valid(previous_closest_building):
			previous_closest_building.get_child(0).get_child(0).material_overlay = null
		var position = _cast_ray_to(event.position)
		if !is_vec_nan(position):
			var building = get_collider(event.position)
			if building.get_parent() is BuildingInstance:
				building = building.get_parent()
				
				building.get_child(0).get_child(0).material_overlay = selected_mat
				previous_closest_building = building
	
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			var position = _cast_ray_to(event.position)
			if !is_vec_nan(position):
				var building = get_collider(event.position)
				if building.get_parent() is BuildingInstance:
					building = building.get_parent()
					
					building_network.remove_building(building)


func _cast_ray_to(position: Vector2):
	var camera = get_viewport().get_camera()
	var from = camera.project_ray_origin(position)
	var to = from + camera.project_ray_normal(position) * camera.far
	return get_world().direct_space_state.intersect_ray(from, to).get("position", Vector3(NAN, NAN, NAN))

func get_collider(position):
	var camera = get_viewport().get_camera()
	var from = camera.project_ray_origin(position)
	var to = from + camera.project_ray_normal(position) * camera.far
	return get_world().direct_space_state.intersect_ray(from, to).get("collider")

func is_vec_nan(vec) -> bool:
	if typeof(vec) == TYPE_VECTOR3:
		return is_nan(vec.x) and is_nan(vec.y) and is_nan(vec.z)
	if typeof(vec) == TYPE_VECTOR2:
		return is_nan(vec.x) and is_nan(vec.y)
	if typeof(vec) == TYPE_REAL:
		return is_nan(vec)
	return false

