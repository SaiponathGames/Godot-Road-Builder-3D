tool
extends Camera

var camera_enabled = true

var edge_scroll_enabled = true
var edge_scroll_detection_area = 0.06
var edge_scroll_time = 5
var edge_scroll_speed = 1

var movement_enabled = true
var movement_time = 5
var movement_speed = 1
var movement_fast_speed_wait_time = 3
var movement_speed_multiplier = 2

var rotation_enabled = true
var rotation_time = 5
var rotation_speed = 3
var rotation_fast_speed_wait_time = 2
var rotation_speed_multiplier = 2

var tilting_enabled = true
var tilting_time = 5
var tilting_speed = 3
var tilting_min_angle = -90
var tilting_max_angle = -20
var tilting_fast_speed_wait_time = 2
var tilting_speed_multiplier = 2

var zooming_enabled = true
var zooming_time = 5
var zooming_speed = 1
var zooming_min_distance = 10
var zooming_max_distance = 80
var zooming_fast_speed_wait_time = 2
var zooming_speed_multiplier = 2

var looking_enabled = true
var looking_speed = 8
var looking_fast_speed_wait_time = 2
var looking_speed_multiplier = 2

var panning_enabled = true
var panning_speed = 20
var panning_fast_speed_wait_time = 2
var panning_speed_multiplier = 2

var scrolling_enabled = true
var scrolling_speed = 30
var scrolling_fast_speed_wait_time = 2
var scrolling_speed_multiplier = 2

## Disable limits in your own risk, this might break the camera.
var limits_enabled = true
var limits_rect = Rect2(Vector2(-2450,-2450), Vector2(4900, 4900))

var perspective_panning_enabled = false
var perspective_panning_speed = 10

var _new_translation
var _new_rotation
var _new_tilt_rotation
var _new_zoom

var _translation_speed = movement_speed
var _translation_time = movement_time

var _edge_speed = edge_scroll_speed
var _edge_time = edge_scroll_time

var _translation_timer = Timer.new()
#var _rotation_timer = Timer.new()
#var _tilting_timer = Timer.new()
#var _zooming_timer = Timer.new()
#var _panning_timer = Timer.new()
#var _looking_timer = Timer.new()
#var _scrolling_timer = Timer.new()

var _mouse_in = true
var _is_panning = false
var _mouse_pressed = false
var _tilt = deg2rad(-45)

var option_target_zoom = true
var option_zoom_to_cursor = false
var option_disable_edge_scrolling_when_using_mouse = true
var option_invert_zooming = false
var option_invert_panning = false
var option_invert_rotation_keys = false
var option_invert_rotation = false
var option_invert_tilting = false
var mouse_sensitivity = 0.03


func _ready() -> void:
	if !Engine.editor_hint:
		$CameraTilt/CameraZoom.current = true

		_setup_timer(_translation_timer, movement_fast_speed_wait_time, "move")
#		_setup_timer(_rotation_timer, rotation_fast_speed_wait_time, "rotate")
#		_setup_timer(_tilting_timer, tilting_fast_speed_wait_time, "tilt")
#		_setup_timer(_zooming_timer, zooming_fast_speed_wait_time, "zoom")
#		_setup_timer(_looking_timer, looking_fast_speed_wait_time, "look")
#		_setup_timer(_panning_timer, panning_fast_speed_wait_time, "pan")
#		_setup_timer(_scrolling_timer, scrolling_fast_speed_wait_time, "scroll")

		add_child(_translation_timer)
#		add_child(_rotation_timer)
#		add_child(_tilting_timer)
#		add_child(_zooming_timer)
#		add_child(_looking_timer)
#		add_child(_panning_timer)
#		add_child(_scrolling_timer)

	_new_translation = global_transform.origin
	_new_rotation = Vector3(0, rotation.y, 0)
	_new_tilt_rotation = Vector3($CameraTilt.rotation.x, 0, 0)
	_new_zoom = $CameraTilt/CameraZoom.translation
	$CameraTilt/CameraZoom.projection = projection

func _input(event: InputEvent) -> void:
	if Engine.editor_hint or !camera_enabled:
		return

	if event is InputEventMouseButton and option_disable_edge_scrolling_when_using_mouse and edge_scroll_enabled:
		if event.button_index in [BUTTON_MIDDLE, BUTTON_RIGHT] and event.pressed:
			_mouse_pressed = true
		if event.button_index in [BUTTON_MIDDLE, BUTTON_RIGHT] and !event.pressed:
			_mouse_pressed = false

	if event is InputEventMouseButton:
		if scrolling_enabled:
			if event.button_index == BUTTON_WHEEL_DOWN:
				_new_zoom += Vector3.BACK * scrolling_speed * mouse_sensitivity * (2 * int(!option_invert_zooming) - 1)
				if option_target_zoom:
					_new_tilt_rotation += Vector3.RIGHT * -deg2rad(tilting_speed) * scrolling_speed/2 * mouse_sensitivity * (2 * int(!option_invert_zooming) - 1)
			if event.button_index == BUTTON_WHEEL_UP:
				_new_zoom += Vector3.BACK * -scrolling_speed * mouse_sensitivity * (2 * int(!option_invert_zooming) - 1)
				if option_target_zoom:
					_new_tilt_rotation += Vector3.RIGHT * deg2rad(tilting_speed) * scrolling_speed/2 * mouse_sensitivity * (2 * int(!option_invert_zooming) - 1)

	if event is InputEventMouseMotion:
		if event.button_mask == BUTTON_MASK_MIDDLE and looking_enabled:
			_new_rotation += Vector3.UP * -event.relative.x * deg2rad(looking_speed) * mouse_sensitivity * (2 * int(!option_invert_rotation) - 1)
			_new_tilt_rotation += Vector3.RIGHT * -event.relative.y * deg2rad(looking_speed) * mouse_sensitivity * (2 * int(!option_invert_tilting) - 1)
			_tilt += -event.relative.y * deg2rad(looking_speed) * mouse_sensitivity * (2 * int(!option_invert_tilting) - 1)

		if event.button_mask == BUTTON_RIGHT:
			if perspective_panning_enabled:
				_new_translation += -(global_transform.basis.z * event.relative.y + global_transform.basis.x * event.relative.x) * perspective_panning_speed * mouse_sensitivity * (2 * int(!option_invert_panning) - 1)
			elif panning_enabled:
				_new_translation += -(global_transform.basis.z * event.relative.normalized().y + global_transform.basis.x * event.relative.normalized().x) * panning_speed * mouse_sensitivity * (2 * int(!option_invert_panning) - 1)

func _process(delta: float) -> void:
	if Engine.editor_hint or !camera_enabled:
		return

	$CameraTilt/CameraZoom.far = far
	var _mouse_position = get_viewport().get_mouse_position()
	var visible_rect = get_viewport().get_visible_rect()
	if edge_scroll_enabled:
		if _mouse_in and !_is_panning and !_mouse_pressed:
			if _mouse_position.x < int(float(visible_rect.size.x)*edge_scroll_detection_area):
				_new_translation -= global_transform.basis.x
				print("left")
			if _mouse_position.x > visible_rect.size.x-(visible_rect.size.x*edge_scroll_detection_area):
				_new_translation += global_transform.basis.x
				print("right")
			if _mouse_position.y < int(float(visible_rect.size.y)*edge_scroll_detection_area):
				_new_translation -= global_transform.basis.z
				print("top")
			if _mouse_position.y > visible_rect.size.y-(visible_rect.size.y*edge_scroll_detection_area):
				_new_translation += global_transform.basis.z
				print("bottom")
			global_transform.origin = global_transform.origin.linear_interpolate(_new_translation*_edge_speed, delta*_edge_time)
			if limits_enabled:
				global_transform.origin = clamp_camera(limits_rect, global_transform.origin)

	if movement_enabled:
		if OS.is_window_focused() and !_is_panning:
			if Input.is_action_just_pressed("camera_forward"):
				if _translation_timer.is_stopped():
					_translation_timer.start()
			if Input.is_action_just_pressed("camera_back"):
				if _translation_timer.is_stopped():
					_translation_timer.start()
			if Input.is_action_just_pressed("camera_left"):
				if _translation_timer.is_stopped():
					_translation_timer.start()
			if Input.is_action_just_pressed("camera_right"):
				if _translation_timer.is_stopped():
					_translation_timer.start()
			if Input.is_action_pressed("camera_forward"):
				_new_translation -= global_transform.basis.z * _translation_speed
			if Input.is_action_pressed("camera_back"):
				_new_translation += global_transform.basis.z * _translation_speed
			if Input.is_action_pressed("camera_left"):
				_new_translation -= global_transform.basis.x * _translation_speed
			if Input.is_action_pressed("camera_right"):
				_new_translation += global_transform.basis.x * _translation_speed
			if Input.is_action_just_released("camera_forward"):
				_translation_timer.stop()
				_translation_speed = movement_speed
				_translation_time = movement_time
			if Input.is_action_just_released("camera_back"):
				_translation_timer.stop()
				_translation_speed = movement_speed
				_translation_time = movement_time
			if Input.is_action_just_released("camera_left"):
				_translation_timer.stop()
				_translation_speed = movement_speed
				_translation_time = movement_time
			if Input.is_action_just_released("camera_right"):
				_translation_timer.stop()
				_translation_speed = movement_speed
				_translation_time = movement_time
			if limits_enabled:
				_new_translation = clamp_camera(limits_rect, _new_translation)
			global_transform.origin = global_transform.origin.linear_interpolate(_new_translation, delta*_translation_time)
#			print(limits_rect.end)
#			$Label.text = "Camera: Motion Translation %s\n" % _motion_translation
			if limits_enabled:
				global_transform.origin = clamp_camera(limits_rect, global_transform.origin)
#				print(_new_translation)

	if rotation_enabled:
		if Input.is_action_pressed("camera_rotate_x"):
			_new_rotation += Vector3.UP * deg2rad(rotation_speed) * (2 * int(!option_invert_rotation_keys) - 1)
		if Input.is_action_pressed("camera_rotate_-x"):
			_new_rotation += Vector3.UP * -deg2rad(rotation_speed) * (2 * int(!option_invert_rotation_keys) - 1)

		_new_rotation.y = wrapf(_new_rotation.y, deg2rad(180), deg2rad(-180))
		rotation = Quat(rotation).slerp(Quat(_new_rotation), delta*rotation_time).get_euler()

	if tilting_enabled:
		if Input.is_action_pressed("camera_tilt_y"):
			_new_tilt_rotation += Vector3.RIGHT * deg2rad(tilting_speed) * (2 * int(!option_invert_tilting) - 1)
			_tilt += deg2rad(tilting_speed) * (2 * int(!option_invert_tilting) - 1)
		if Input.is_action_pressed("camera_tilt_-y"):
			_new_tilt_rotation += Vector3.RIGHT * -deg2rad(tilting_speed) * (2 * int(!option_invert_tilting) - 1)
			_tilt += -deg2rad(tilting_speed) * (2 * int(!option_invert_tilting) - 1)

		_new_tilt_rotation.x = clamp(_new_tilt_rotation.x, deg2rad(tilting_min_angle), deg2rad(tilting_max_angle))
		_tilt = clamp(_tilt, deg2rad(tilting_min_angle), deg2rad(tilting_max_angle))
		$CameraTilt.rotation = Quat($CameraTilt.rotation).slerp(Quat(_new_tilt_rotation), delta*tilting_time).get_euler()

	if zooming_enabled:
		if Input.is_action_pressed("camera_zoom_in"):
			_new_zoom += Vector3.BACK * zooming_speed * (2 * int(!option_invert_zooming) - 1)
			if option_target_zoom:
				_new_tilt_rotation += Vector3.RIGHT * -deg2rad(tilting_speed) * zooming_speed/2 * (2 * int(!option_invert_zooming) - 1)
		if Input.is_action_pressed("camera_zoom_out"):
			_new_zoom += Vector3.BACK * -zooming_speed * (2 * int(!option_invert_zooming) - 1)
			if option_target_zoom:
				_new_tilt_rotation += Vector3.RIGHT * deg2rad(tilting_speed) * zooming_speed/2 * (2 * int(!option_invert_zooming) - 1)
		if option_target_zoom:
			_new_tilt_rotation.x = clamp(_new_tilt_rotation.x, tilting_min_angle, _tilt)

		var current_translation
		if option_zoom_to_cursor:
			current_translation = _cast_ray_to(_mouse_position)
		_new_zoom.z = clamp(_new_zoom.z, zooming_min_distance, zooming_max_distance)
		$CameraTilt/CameraZoom.translation = $CameraTilt/CameraZoom.translation.linear_interpolate(_new_zoom, delta*zooming_time)
		if current_translation != null and current_translation != Vector3.INF:
			var new_translation = _cast_ray_to(_mouse_position)
			if new_translation != null and new_translation != Vector3.INF:
				_new_translation += (current_translation - new_translation)
	$PanelContainer/Label.text = "DEBUG INFO\n"
	$PanelContainer/Label.text += "Camera: Position %s\n" % global_transform.origin 
	$PanelContainer/Label.text += "Camera: Target Position %s\n" % _new_translation 
	$PanelContainer/Label.text += "Engine: FPS %s\n" % Engine.get_frames_per_second()

func clamp_camera(rect: Rect2, position: Vector3):
	return Vector3(clamp(position.x, rect.position.x, rect.end.x), position.y, clamp(position.z, rect.position.y, rect.end.y))

func _cast_ray_to(postion: Vector2) -> Vector3:
	var camera = get_viewport().get_camera()
	var from = camera.project_ray_origin(postion)
	var to = from + camera.project_ray_normal(postion) * camera.far
	return get_world().direct_space_state.intersect_ray(from, to).get("position", Vector3.INF)

func _timeout(movement):
	match movement:
		"move":
			_translation_speed *= movement_speed_multiplier
			_translation_time /= movement_speed_multiplier
			print(_translation_speed)
			print(_translation_time)

func _setup_timer(timer: Timer, wait_time: float, type: String) -> void:
	timer.wait_time = wait_time
	timer.one_shot = true
	timer.connect("timeout", self, "_timeout", [type])

func _get_property_list() -> Array:
	var properties = []
	properties.append({
		"name": "camera/enabled",
		"type": TYPE_BOOL,
		"usage": PROPERTY_USAGE_DEFAULT
	})
	properties.append({
		"name": "edge_scroll/enabled",
		"type": TYPE_BOOL,
		"usage": PROPERTY_USAGE_DEFAULT if camera_enabled else PROPERTY_USAGE_STORAGE
	})
	properties.append({
		"name": "movement/enabled",
		"type": TYPE_BOOL,
		"usage": PROPERTY_USAGE_DEFAULT if camera_enabled else PROPERTY_USAGE_STORAGE
	})
	properties.append({
		"name": "rotation/enabled",
		"type": TYPE_BOOL,
		"usage": PROPERTY_USAGE_DEFAULT if camera_enabled else PROPERTY_USAGE_STORAGE
	})
	properties.append({
		"name": "tilting/enabled",
		"type": TYPE_BOOL,
		"usage": PROPERTY_USAGE_DEFAULT if camera_enabled else PROPERTY_USAGE_STORAGE
	})
	properties.append({
		"name": "zooming/enabled",
		"type": TYPE_BOOL,
		"usage": PROPERTY_USAGE_DEFAULT if camera_enabled else PROPERTY_USAGE_STORAGE
	})
	properties.append({
		"name": "looking/enabled",
		"type": TYPE_BOOL,
		"usage": PROPERTY_USAGE_DEFAULT if camera_enabled else PROPERTY_USAGE_STORAGE
	})
	properties.append({
		"name": "panning/enabled",
		"type": TYPE_BOOL,
		"usage": PROPERTY_USAGE_DEFAULT if camera_enabled else PROPERTY_USAGE_STORAGE
	})
	properties.append({
	"name": "edge_scroll/detection_area",
	"type": TYPE_REAL,
	"usage": PROPERTY_USAGE_DEFAULT if camera_enabled and edge_scroll_enabled else PROPERTY_USAGE_STORAGE
	})
	properties.append({
	"name": "edge_scroll/time",
	"type": TYPE_REAL,
	"usage": PROPERTY_USAGE_DEFAULT if camera_enabled and edge_scroll_enabled else PROPERTY_USAGE_STORAGE
	})
	properties.append({
	"name": "edge_scroll/speed",
	"type": TYPE_REAL,
	"usage": PROPERTY_USAGE_DEFAULT if camera_enabled and edge_scroll_enabled else PROPERTY_USAGE_STORAGE
	})
	properties.append({
	"name": "movement/time",
	"type": TYPE_REAL,
	"usage": PROPERTY_USAGE_DEFAULT if camera_enabled and movement_enabled else PROPERTY_USAGE_STORAGE
	})
	properties.append({
	"name": "movement/speed",
	"type": TYPE_REAL,
	"usage": PROPERTY_USAGE_DEFAULT if camera_enabled and movement_enabled else PROPERTY_USAGE_STORAGE
	})
	properties.append({
	"name": "rotation/time",
	"type": TYPE_REAL,
	"usage": PROPERTY_USAGE_DEFAULT if camera_enabled and rotation_enabled else PROPERTY_USAGE_STORAGE
	})
	properties.append({
	"name": "rotation/speed",
	"type": TYPE_REAL,
	"usage": PROPERTY_USAGE_DEFAULT if camera_enabled and rotation_enabled else PROPERTY_USAGE_STORAGE
	})
	properties.append({
	"name": "tilting/time",
	"type": TYPE_REAL,
	"usage": PROPERTY_USAGE_DEFAULT if camera_enabled and tilting_enabled else PROPERTY_USAGE_STORAGE
	})
	properties.append({
	"name": "tilting/speed",
	"type": TYPE_REAL,
	"usage": PROPERTY_USAGE_DEFAULT if camera_enabled and tilting_enabled else PROPERTY_USAGE_STORAGE
	})
	properties.append({
	"name": "tilting/min_angle",
	"type": TYPE_REAL,
	"usage": PROPERTY_USAGE_DEFAULT if camera_enabled and tilting_enabled else PROPERTY_USAGE_STORAGE
	})
	properties.append({
	"name": "tilting/max_angle",
	"type": TYPE_REAL,
	"usage": PROPERTY_USAGE_DEFAULT if camera_enabled and tilting_enabled else PROPERTY_USAGE_STORAGE
	})
	properties.append({
	"name": "zooming/time",
	"type": TYPE_REAL,
	"usage": PROPERTY_USAGE_DEFAULT if camera_enabled and zooming_enabled else PROPERTY_USAGE_STORAGE
	})
	properties.append({
	"name": "zooming/speed",
	"type": TYPE_REAL,
	"usage": PROPERTY_USAGE_DEFAULT if camera_enabled and zooming_enabled else PROPERTY_USAGE_STORAGE
	})
	properties.append({
	"name": "zooming/min_distance",
	"type": TYPE_REAL,
	"usage": PROPERTY_USAGE_DEFAULT if camera_enabled and zooming_enabled else PROPERTY_USAGE_STORAGE
	})
	properties.append({
	"name": "zooming/max_distance",
	"type": TYPE_REAL,
	"usage": PROPERTY_USAGE_DEFAULT if camera_enabled and zooming_enabled else PROPERTY_USAGE_STORAGE
	})
	properties.append({
	"name": "looking/speed",
	"type": TYPE_REAL,
	"usage": PROPERTY_USAGE_DEFAULT if camera_enabled and looking_enabled else PROPERTY_USAGE_STORAGE
	})
	properties.append({
	"name": "panning/speed",
	"type": TYPE_REAL,
	"usage": PROPERTY_USAGE_DEFAULT if camera_enabled and panning_enabled else PROPERTY_USAGE_STORAGE
	})
	properties.append({
	"name": "perspective_panning/enabled",
	"type": TYPE_BOOL,
	"usage": PROPERTY_USAGE_DEFAULT if camera_enabled else PROPERTY_USAGE_STORAGE
	})
	properties.append({
	"name": "perspective_panning/speed",
	"type": TYPE_REAL,
	"usage": PROPERTY_USAGE_DEFAULT if camera_enabled and perspective_panning_enabled else PROPERTY_USAGE_STORAGE
	})
	properties.append({
	"name": "mouse/sensitivity",
	"type": TYPE_REAL,
	"usage": PROPERTY_USAGE_DEFAULT if camera_enabled else PROPERTY_USAGE_STORAGE
	})
	properties.append({
	"name": "option/disable_edge_scrolling_when_using_mouse",
	"type": TYPE_BOOL,
	"usage": PROPERTY_USAGE_DEFAULT if camera_enabled else PROPERTY_USAGE_STORAGE
	})
	properties.append({
	"name": "option/target_zoom",
	"type": TYPE_BOOL,
	"usage": PROPERTY_USAGE_DEFAULT if camera_enabled else PROPERTY_USAGE_STORAGE
	})
	properties.append({
	"name": "option/zoom_to_cursor",
	"type": TYPE_BOOL,
	"usage": PROPERTY_USAGE_DEFAULT if camera_enabled else PROPERTY_USAGE_STORAGE
	})
	properties.append({
	"name": "option/invert/zooming",
	"type": TYPE_BOOL,
	"usage": PROPERTY_USAGE_DEFAULT if camera_enabled else PROPERTY_USAGE_STORAGE
	})
	properties.append({
	"name": "option/invert/panning",
	"type": TYPE_BOOL,
	"usage": PROPERTY_USAGE_DEFAULT if camera_enabled else PROPERTY_USAGE_STORAGE
	})
	properties.append({
	"name": "option/invert/rotation",
	"type": TYPE_BOOL,
	"usage": PROPERTY_USAGE_DEFAULT if camera_enabled else PROPERTY_USAGE_STORAGE
	})
	properties.append({
	"name": "option/invert/rotation_keys",
	"type": TYPE_BOOL,
	"usage": PROPERTY_USAGE_DEFAULT if camera_enabled else PROPERTY_USAGE_STORAGE
	})
	properties.append({
	"name": "option/invert/tilting",
	"type": TYPE_BOOL,
	"usage": PROPERTY_USAGE_DEFAULT if camera_enabled else PROPERTY_USAGE_STORAGE
	})
	properties.append({
	"name": "limits/enabled",
	"type": TYPE_BOOL,
	"usage": PROPERTY_USAGE_DEFAULT if camera_enabled else PROPERTY_USAGE_STORAGE
	})
	properties.append({
	"name": "limits/rect",
	"type": TYPE_RECT2,
	"usage": PROPERTY_USAGE_DEFAULT if camera_enabled and limits_enabled else PROPERTY_USAGE_STORAGE
	})
	return properties

func _get(property: String):
	if str(property).begins_with("camera"):
		var edited_property = str(property).trim_prefix("camera/")
		match edited_property:
			"enabled":
				return camera_enabled

	if str(property).begins_with("limits"):
		var edited_property = str(property).trim_prefix("limits/")
		match edited_property:
			"enabled":
				return limits_enabled
			"rect":
				return limits_rect

	if str(property).begins_with("perspective_panning"):
		var edited_property = str(property).trim_prefix("perspective_panning/")
		match edited_property:
			"enabled":
				return perspective_panning_enabled
			"speed":
				return perspective_panning_speed

	if str(property).begins_with("edge_scroll"):
		var edited_property = str(property).trim_prefix("edge_scroll/")
		match edited_property:
			"enabled":
				return edge_scroll_enabled
			"detection_area":
				return edge_scroll_detection_area
			"time":
				return edge_scroll_time
			"speed":
				return edge_scroll_speed

	if str(property).begins_with("movement"):
		var edited_property = str(property).trim_prefix("movement/")
		match edited_property:
			"enabled":
				return movement_enabled
			"time":
				return movement_time
			"speed":
				return movement_speed

	if str(property).begins_with("rotation"):
		var edited_property = str(property).trim_prefix("rotation/")
		match edited_property:
			"enabled":
				return rotation_enabled
			"time":
				return rotation_time
			"speed":
				return rotation_speed

	if str(property).begins_with("tilting"):
		var edited_property = str(property).trim_prefix("tilting/")
		match edited_property:
			"enabled":
				return tilting_enabled
			"time":
				return tilting_time
			"speed":
				return tilting_speed
			"min_angle":
				return tilting_min_angle
			"max_angle":
				return tilting_max_angle

	if str(property).begins_with("zooming"):
		var edited_property = str(property).trim_prefix("zooming/")
		match edited_property:
			"enabled":
				return zooming_enabled
			"time":
				return zooming_time
			"speed":
				return zooming_speed
			"min_distance":
				return zooming_min_distance
			"max_distance":
				return zooming_max_distance

	if str(property).begins_with("panning"):
		var edited_property = str(property).trim_prefix("panning/")
		match edited_property:
			"enabled":
				return panning_enabled
			"speed":
				return panning_speed

	if str(property).begins_with("looking"):
		var edited_property = str(property).trim_prefix("looking/")
		match edited_property:
			"enabled":
				return looking_enabled
			"speed":
				return looking_speed

	if str(property).begins_with("mouse"):
		var edited_property = str(property).trim_prefix("mouse/")
		match edited_property:
			"sensitivity":
				return mouse_sensitivity

	if str(property).begins_with("option"):
		var edited_property = str(property).trim_prefix("option/")
		match edited_property:
			"disable_edge_scrolling_when_using_mouse":
				return option_disable_edge_scrolling_when_using_mouse
			"target_zoom":
				return option_target_zoom
			"zoom_to_cursor":
				return option_zoom_to_cursor
		if edited_property.begins_with("invert"):
			var inverted_property = str(property).trim_prefix("option/")
			match inverted_property:
				"zooming":
					return option_invert_zooming
				"panning":
					return option_invert_panning
				"rotation":
					return option_invert_rotation
				"rotation_keys":
					return option_invert_rotation_keys
				"tilting":
					return option_invert_tilting


func _set(property: String, value) -> bool:
	if str(property).begins_with("camera"):
		var edited_property = str(property).trim_prefix("camera/")
		match edited_property:
			"enabled":
				camera_enabled = value
				property_list_changed_notify()
				return true

	if str(property).begins_with("limits"):
		var edited_property = str(property).trim_prefix("limits/")
		match edited_property:
			"enabled":
				limits_enabled = value
				property_list_changed_notify()
				return true
			"rect":
				limits_rect = value
				return true

	if str(property).begins_with("perspective_panning"):
		var edited_property = str(property).trim_prefix("perspective_panning/")
		match edited_property:
			"enabled":
				perspective_panning_enabled = value
				panning_enabled = !value
				property_list_changed_notify()
				return true
			"speed":
				perspective_panning_speed = value
				return true

	if str(property).begins_with("edge_scroll"):
		var edited_property = str(property).trim_prefix("edge_scroll/")
		match edited_property:
			"enabled":
				edge_scroll_enabled = value
				property_list_changed_notify()
				return true
			"detection_area":
				edge_scroll_detection_area = value
				return true
			"time":
				edge_scroll_time = value
				return true
			"speed":
				edge_scroll_speed = value
				return true
	if str(property).begins_with("movement"):
		var edited_property = str(property).trim_prefix("movement/")
		match edited_property:
			"enabled":
				movement_enabled = value
				property_list_changed_notify()
				return true
			"time":
				movement_time = value
				return true
			"speed":
				movement_speed = value
				return true

	if str(property).begins_with("rotation"):
		var edited_property = str(property).trim_prefix("rotation/")
		match edited_property:
			"enabled":
				rotation_enabled = value
				property_list_changed_notify()
				return true
			"time":
				rotation_time = value
				return true
			"speed":
				rotation_speed = value
				return true

	if str(property).begins_with("tilting"):
		var edited_property = str(property).trim_prefix("tilting/")
		match edited_property:
			"enabled":
				tilting_enabled = value
				property_list_changed_notify()
				return true
			"time":
				tilting_time = value
				return true
			"speed":
				tilting_speed = value
				return true
			"min_angle":
				tilting_min_angle = value
				return true
			"max_angle":
				tilting_max_angle = value
				return true

	if str(property).begins_with("zooming"):
		var edited_property = str(property).trim_prefix("zooming/")
		match edited_property:
			"enabled":
				zooming_enabled = value
				property_list_changed_notify()
				return true
			"time":
				zooming_time = value
				return true
			"speed":
				zooming_speed = value
				return true
			"min_distance":
				zooming_min_distance = value
				return true
			"max_distance":
				zooming_max_distance = value
				return true

	if str(property).begins_with("panning"):
		var edited_property = str(property).trim_prefix("panning/")
		match edited_property:
			"enabled":
				panning_enabled = value
				perspective_panning_enabled = !value
				property_list_changed_notify()
				return true
			"speed":
				panning_speed = value
				return true

	if str(property).begins_with("looking"):
		var edited_property = str(property).trim_prefix("looking/")
		match edited_property:
			"enabled":
				looking_enabled = value
				property_list_changed_notify()
				return true
			"speed":
				looking_speed = value
				return true
	if str(property).begins_with("mouse"):
		var edited_property = str(property).trim_prefix("mouse/")
		match edited_property:
			"sensitivity":
				mouse_sensitivity = value
				return true

	if str(property).begins_with("option"):
		var edited_property = str(property).trim_prefix("option/")
		match edited_property:
			"disable_edge_scrolling_when_using_mouse":
				option_disable_edge_scrolling_when_using_mouse = value
				return true
			"target_zoom":
				option_target_zoom = value
				return true
			"zoom_to_cursor":
				option_zoom_to_cursor = value
				return true
		if edited_property.begins_with("invert"):
			var inverted_property = str(property).trim_prefix("option/")
			match inverted_property:
				"zooming":
					option_invert_zooming = value
					return true
				"panning":
					option_invert_panning = value
					return true
				"rotation":
					option_invert_rotation = value
					return true
				"rotation_keys":
					option_invert_rotation_keys = value
					return true
				"tilting":
					option_invert_tilting = value
					return true

	return false

func _notification(what: int) -> void:
	match what:
		NOTIFICATION_WM_MOUSE_ENTER:
			_mouse_in = true
		NOTIFICATION_WM_MOUSE_EXIT:
			_mouse_in = false
