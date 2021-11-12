extends Resource
class_name BuildingType

var name: String
var id: String
var scene: PackedScene
var door_face_direction = Vector3.ZERO
var width = 2

func instance():
	var building_inst = scene.instance()
	building_inst.building = self
	building_inst.id = id
	return building_inst

func _init(_id, _name, _scene, _width = 2):
	self.id = _id
	self.name = _name
	self.scene = _scene
	self.width = width
