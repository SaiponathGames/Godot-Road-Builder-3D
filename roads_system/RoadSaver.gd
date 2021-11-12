extends Spatial

export var road_net_np: NodePath
onready var road_net = get_node(road_net_np)

func _input(event):
	if event is InputEventKey:
		if event.scancode == KEY_KP_9 and event.pressed:
			save(road_net)
		if event.scancode == KEY_KP_8 and event.pressed:
			var image = Image.new()
			image.load("user://test.png")
			load_road(image, road_net)

func save(network: RoadNetwork):
	var image = Image.new()
	image.create(512, 512, false, Image.FORMAT_RGBA8)
	for connection in network.network.values():
		var points = connection.get_points()
		for point in points:
			image.lock()
			image.set_pixel(point.x, point.z, Color.red)
			image.unlock()
	for intersection in network.intersections:
		image.lock()
		image.set_pixel(intersection.position.x, intersection.position.z, Color.white)
		image.unlock()
	
	image.save_png("user://test.png")
	OS.shell_open(ProjectSettings.globalize_path("user://"))
	
func load_road(image: Image, network: RoadNetwork):
	for x in image.get_width():
		for y in image.get_height():
			image.lock()
			var color = image.get_pixel(x, y)
			if color == Color.white:
				pass
			if color == Color.red:
				print("Road segment")
				
			image.unlock()
