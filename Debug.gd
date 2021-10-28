extends Control


func _process(delta):
	$Label.text = ""
	$Label.text += "FPS: %d\n" % Engine.get_frames_per_second()
	$Label.text += "BuildingPlacer.is_buildable: %s" % [$"../Tools/BuildingTool".is_buildable]
