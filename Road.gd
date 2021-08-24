tool
extends Path

onready var road_mesh: CSGPolygon = $RoadMesh


func _get_property_list() -> Array:
	var properties = []
	properties.append({
		"name": "road_polygon",
		"type": TYPE_VECTOR3_ARRAY
	})
	properties.append({
		"name": "road_interval",
		"type": TYPE_REAL,
		"hint": PROPERTY_HINT_RANGE,
		"hint_string": "0.001,3,0.001,slider"
	})
	properties.append({
		"name": "material",
		"type": TYPE_OBJECT,
		"hint": PROPERTY_HINT_RESOURCE_TYPE,
		"hint_string": "SpatialMaterial,ShaderMaterial"
	})
	return properties

func _get(property: String):
	if !is_inside_tree():
		return

	match property:
		"road_interval":
			return road_mesh.path_interval
		"road_polygon":
			return road_mesh.polygon
		"material":
			return road_mesh.material
	return null

func _set(property: String, value) -> bool:
	if !is_inside_tree():
		return false
	match property:
		"road_interval":
			road_mesh.path_interval = value
			return true
		"road_polygon":
			road_mesh.polygon = value
			return true
		"material":
			road_mesh.material = value
			return true
	return false
