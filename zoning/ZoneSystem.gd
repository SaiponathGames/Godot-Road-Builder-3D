extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var grid_node = $GridNode

var grids = []

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_RoadNetwork_road_segment_created(segment: RoadSegmentBase):
	print("SEGMENT CREATED", segment)
	print('creating zones!')
	
	var dir = segment.start_position.direction
	DrawingUtils.draw_line($ImmediateGeometry, segment.start_position.position, segment.start_position.position + dir * 10, Color.webgreen)
	var left = Vector3(-dir.z, dir.y, dir.x).normalized()
	DrawingUtils.draw_line($ImmediateGeometry, segment.start_position.position, segment.start_position.position + left * 10, Color.webgreen)
	

	var z_padding = 0.015
	var z_lr_padding = 2  # LR = Left Right

	var z_start = segment.road_network_info.segment_width/2 + z_padding
	var zone_height = 4
	var z_end = zone_height+z_padding

	var seg_start_pos = segment.start_position.position
	var seg_end_pos = segment.end_position.position

	var zone_start_start_pos = seg_start_pos - z_start * left + z_lr_padding * dir
	DrawingUtils.draw_empty_circle($ImmediateGeometry, zone_start_start_pos, 0.25, Color.blue)
	var zone_end_start_pos = seg_start_pos - z_end * left + z_lr_padding * dir
	DrawingUtils.draw_empty_circle($ImmediateGeometry, zone_end_start_pos, 0.25, Color.yellow)
	var zone_start_end_pos = seg_end_pos - z_start * left - z_lr_padding * dir
	DrawingUtils.draw_empty_circle($ImmediateGeometry, zone_start_end_pos, 0.25, Color.orange)
	var zone_end_end_pos = seg_end_pos - z_end * left - z_lr_padding * dir
	DrawingUtils.draw_empty_circle($ImmediateGeometry, zone_end_end_pos, 0.25, Color.maroon)
	
	var grid = grid_node.create_grid(str(segment.id), zone_end_start_pos, zone_start_end_pos)
	print("GRID: ", grid)
	grids.append(grid)
#	var pos_point = zone_end_start_pos+zone_start_end_pos/2
#	var a = segment.project_point(pos_point)
#	var dir_seg = segment.direction_from(0)
#	var angle_a = atan2(a.z, a.x)
#	var angle_b = atan2(dir_seg.z, dir_seg.x)
#	var angle = angle_b - angle_a
#	prints(angle_a, angle_b, angle)
#	grid.rotation = Basis.IDENTITY.rotated(Vector3.UP, angle)
	grid.draw()
	
#	var zone_start_start_pos_mir = seg_start_pos + z_start * left + z_lr_padding * dir
#	var zone_end_start_pos_mir = seg_start_pos + z_end * left + z_lr_padding * dir
#	var zone_start_end_pos_mir = seg_end_pos + z_start * left - z_lr_padding * dir
#	var zone_end_end_pos_mir = seg_end_pos + z_end * left - z_lr_padding * dir
#
#	DrawingUtils.draw_line(
#		$ImmediateGeometry, 
#		segment.start_position.position - 1.015 * left, 
#		segment.end_position.position - 1.015 * left
#	)
#	DrawingUtils.draw_line(
#		$ImmediateGeometry, 
#		segment.start_position.position + 1.015 * left,
#		segment.end_position.position + 1.015 * left
#	)
#
#	DrawingUtils.draw_line(
#		$ImmediateGeometry,
#		zone_start_start_pos,
#		zone_end_start_pos
#	)
#	DrawingUtils.draw_line(
#		$ImmediateGeometry,
#		zone_start_end_pos,
#		zone_end_end_pos
#	)
#	DrawingUtils.draw_line(
#		$ImmediateGeometry,
#		zone_start_start_pos_mir,
#		zone_end_start_pos_mir
#	)
#	DrawingUtils.draw_line(
#		$ImmediateGeometry,
#		zone_start_end_pos_mir,
#		zone_end_end_pos_mir
#	)
#	DrawingUtils.draw_line(
#		$ImmediateGeometry,
#		zone_end_start_pos,
#		zone_end_end_pos
#	)
#
#	DrawingUtils.draw_line(
#		$ImmediateGeometry,
#		zone_end_start_pos_mir,
#		zone_end_end_pos_mir
#	)
#
#	var length = segment.length
#	var grid_size_x = 2
#	var num_x = round(length/grid_size_x)
#	var num_y = (zone_height/grid_size_x)
#	for i in range(num_y):
#		var t = i/float(num_y)
#		var y_start = lerp(zone_start_start_pos, zone_end_start_pos, t)
#		var y_end = lerp(zone_start_end_pos, zone_end_end_pos, t)
#		var y_start_mir = lerp(zone_start_start_pos_mir, zone_end_start_pos_mir, t)
#		var y_end_mir = lerp(zone_start_end_pos_mir, zone_end_end_pos_mir, t)
#
#		DrawingUtils.draw_line(
#			$ImmediateGeometry,
#			y_start, y_end
#		)
#
#		DrawingUtils.draw_line(
#			$ImmediateGeometry,
#			y_start_mir, y_end_mir
#		)
#
#	for i in range(num_x):
#		var t = i/float(num_x)
#		var start = lerp(zone_start_start_pos, zone_start_end_pos, t)
#		var start_mir = lerp(zone_start_start_pos_mir, zone_start_end_pos_mir, t)
#		var end = lerp(zone_end_start_pos, zone_end_end_pos, t)
#		var end_mir = lerp(zone_end_start_pos_mir, zone_end_end_pos_mir, t)
#
#
#		DrawingUtils.draw_line(
#			$ImmediateGeometry,
#			start, end
#		)
#
#		DrawingUtils.draw_line(
#			$ImmediateGeometry,
#			start_mir, end_mir
#		)
	



func _on_RoadNetwork_road_segment_deleted(segment: RoadSegmentBase):
	print("SEGMENT DELETED", segment)
	
	grid_node.delete_grid(str(segment.id))
