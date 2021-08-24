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

var current_road

export var distance_to_create_new_road = 1

var create_new_road = false

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			if !is_dragging: # start
				_drag_start = _cast_ray_to(event.position)
				$RoadPreview.curve.add_point(_drag_start)
				is_dragging = true
				print(_drag_start.distance_to(_drag_end))
				if _drag_start.distance_to(_drag_end) > distance_to_create_new_road:
					print("will create new road")
					create_new_road = true
					current_road = null
				print("Starting drag")

			elif is_dragging: # end
				_drag_end = _cast_ray_to(event.position)
				if create_new_road:
					print("Creating new road")
					$RoadPreview.curve.add_point(_drag_end)
					var road = road_scene.instance()
					add_child(road)
					print(road)
					for point in $RoadPreview.curve.tessellate():
						road.curve.add_point(point)
					current_road = road
					print(current_road)
					$RoadPreview.curve.clear_points()
					print($RoadPreview.curve._data)
					is_dragging = continue_dragging

				elif continue_dragging and current_road:
					print("Adding to existing road")
					$RoadPreview.curve.add_point(_drag_end)
					for point in $RoadPreview.curve.tessellate():
						current_road.curve.add_point(point)
					$RoadPreview.curve.clear_points()
					is_dragging = continue_dragging
				print("Drag ended!")

		if event.button_index == BUTTON_RIGHT and event.pressed:
			if is_dragging:
				is_dragging = false
				_drag_start = Vector3.ZERO
				_drag_current = Vector3.ZERO
				$RoadPreview.curve.clear_points()
				print("Cancelling!")

	if event is InputEventMouseMotion:
		if is_dragging:
			if continue_dragging and current_road:
				create_new_road = false
				print("Fixing..")
			if $RoadPreview.curve.get_point_count() > 1:
				$RoadPreview.curve.remove_point($RoadPreview.curve.get_point_count()-1)
			_drag_current = _cast_ray_to(event.position)
			$RoadPreview.curve.add_point(_drag_current)


func _cast_ray_to(postion: Vector2):
	var camera = get_viewport().get_camera()
	var from = camera.project_ray_origin(postion)
	var to = from + camera.project_ray_normal(postion) * camera.far
	return get_world().direct_space_state.intersect_ray(from, to).get("position", Vector3(NAN, NAN, NAN))

