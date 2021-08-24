extends Spatial

var _is_dragging = false

var continue_drag = true
var _drag_start = Vector3.ZERO
var _drag_current = Vector3.ZERO
var straight_road = false
var can_build = true

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			if !_is_dragging:
				_drag_start = _cast_ray_to(event.position)
				$Path2.curve.add_point(_drag_start)
				_is_dragging = true
				print("Started dragging")
			elif _is_dragging:
				if can_build:
					if straight_road:
						$Path.curve.add_point(_drag_start)
					var _drag_end = _cast_ray_to(event.position)
					for point in $Path2.curve.get_baked_points():
						if _negate_condition(Array($Path.curve._data["points"]).has(point), !straight_road):
							$Path.curve.add_point(point)
	#					else:
	#						print("$Path2 has point %s" % point)
					$Path.curve.add_point(_drag_end)
					$Path2.curve.clear_points()
					_is_dragging = continue_drag
					_drag_start = _drag_end
					print("drag ended")
				can_build = true
		if event.button_index == BUTTON_RIGHT and event.pressed:
			if _is_dragging:
				_is_dragging = false
				_drag_start = Vector3.ZERO
				_drag_current = Vector3.ZERO
				can_build = true
				$Path2.curve.clear_points()
	if event is InputEventMouseMotion and _is_dragging:
		print("Dragging now")
		_drag_current = _cast_ray_to(event.position)
		if !Array($Path2.curve._data["points"]).has(_drag_current):
			$Path2.curve.add_point(_drag_current)


		var points =  $Path2.curve.get_baked_points()
		$Path2.curve.clear_points()
		var points_in_preview_path = PoolVector3Array()
		for point in points:
			if Array($Path.curve.get_baked_points()).has(point) and point != points[0]:
				print(point)
				points_in_preview_path.append(point)
			$Path2.curve.add_point(point)
		if !points_in_preview_path.empty():
			can_build = false
		else:
			can_build = true

func _cast_ray_to(postion: Vector2):
	var camera = get_viewport().get_camera()
	var from = camera.project_ray_origin(postion)
	var to = from + camera.project_ray_normal(postion) * camera.far
	return get_world().direct_space_state.intersect_ray(from, to).get("position", Vector3(NAN, NAN, NAN))

static func _negate_condition(value: bool, condition: bool):
	return bool((int(condition) ^ -int(value)) + int(value))
