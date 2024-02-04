extends Resource
class_name BuildingType

export var name: String
export var id: String
export var scene: PackedScene
export var face_direction: Vector3 = Vector3.ZERO
export var dimensions: Vector3

func instance_at(transform: Transform) -> BuildingInstance:
	var building_inst = scene.instance()
	building_inst.transform = transform
	
	building_inst.building = self
	return building_inst

func _init(_id, _name, _scene, _width = 2):
	self.id = _id
	self.name = _name
	self.scene = _scene
	self.width = _width
