extends Spatial

const Grid = preload("res://zoning/GridResource.gd")

var grids = {}

onready var immediate_geo: ImmediateGeometry = $ImmediateGeometry

func _ready():
	pass

func create_grid(grid_id: String, from_vec: Vector3, to_vec: Vector3) -> Grid:
	var bounds = AABB(from_vec, Vector3.ZERO)
	bounds.end = to_vec
	var grid = Grid.new(bounds)
	grid.set_drawing_node(immediate_geo)
	grids[grid_id] = grid
	return grid

func delete_grid(grid_id: String):
	var grid = get_grid(grid_id)
	remove_grid(grid_id)
	print(grid)

func remove_grid(grid_id: String):
	grids.erase(grid_id)

func get_grid(grid_id: String):
	return grids[grid_id]

func get_grid_id(grid: Grid):
	for grid_id in grids:
		if grids[grid_id] == grid:
			return grid
