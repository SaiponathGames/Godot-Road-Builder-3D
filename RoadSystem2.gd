extends Spatial

var road_scene = preload("res://Road.tscn")
var straight_tool = true
var continue_dragging = true

var is_dragging = false
var _drag_start = Vector3.ZERO
var _drag_current = Vector3.ZERO
var _drag_last_current = Vector3.ZERO
var _drag_last_index = -1
var _drag_end = Vector3.ZERO

var button_pressed = false

var current_road

export var distance_to_create_new_road = 1

var create_new_road = false

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			button_pressed = event.pressed

		if event.button_index == BUTTON_LEFT and event.pressed:
			if !is_dragging: # start
				_drag_start = _cast_ray_to(event.position)
				is_dragging = true

				var road = road_scene.instance()
				add_child(road)
				current_road = road
				current_road.curve.add_point(_drag_start)
				current_road.curve.add_point(_drag_start)


			elif is_dragging: # end
				_drag_end = _cast_ray_to(event.position)

				current_road.curve.add_point(_drag_end)
				var count = current_road.curve.get_point_count()

				var previous_point = current_road.curve.get_point_position(count-2)
				current_road.curve.set_point_out(count-2, _drag_end - previous_point)
				current_road.curve.set_point_in(count-1, previous_point - _drag_end)

				$RoadPreview.curve.clear_points()
				is_dragging = continue_dragging

		if event.button_index == BUTTON_RIGHT and event.pressed:
			if is_dragging:
				is_dragging = false
				_drag_start = Vector3.ZERO
				_drag_current = Vector3.ZERO
				$RoadPreview.curve.clear_points()
				print("Cancelling!")

	if event is InputEventMouseMotion:
		if is_dragging:
			if not button_pressed:
				current_road.curve.remove_point(current_road.curve.get_point_count()-1)
			_drag_current = _cast_ray_to(event.position)
			current_road.curve.add_point(_drag_current)

func _cast_ray_to(postion: Vector2):
	var camera = get_viewport().get_camera()
	var from = camera.project_ray_origin(postion)
	var to = from + camera.project_ray_normal(postion) * camera.far
	return get_world().direct_space_state.intersect_ray(from, to).get("position", Vector3(NAN, NAN, NAN))

