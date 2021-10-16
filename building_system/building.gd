extends Resource
class_name BuildingType

var name: String
var id: String
var scene: PackedScene
var door_face_direction = Vector3(1, 0, 0)

func instance():
	return scene.instance()

func _init(_id, _name, _scene):
	self.id = _id
	self.name = _name
	self.scene = _scene
