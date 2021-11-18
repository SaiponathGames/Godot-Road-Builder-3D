extends Control


func _process(_delta):
	$Label.text = ""
	$Label.text += "FPS: %d\n" % Engine.get_frames_per_second()
	$Label.text += "BuildingPlacer.is_buildable: %s" % [$"../Tools/BuildingTool".is_buildable]
