extends Node


# taken from https://godotengine.org/qa/5175/how-to-get-all-the-files-inside-a-folder
func get_dir_contents(rootPath: String) -> Array:
	var files = []
	var directories = []
	var dir = Directory.new()
	var error = dir.open(rootPath)
	if error == OK:
		dir.list_dir_begin(true, false)
		_add_dir_contents(dir, files, directories)
	else:
		push_error("An error occurred when trying to access the path, %s, error: %s" % [rootPath, error])

	return [files, directories]

func _add_dir_contents(dir: Directory, files: Array, directories: Array):
	var file_name = dir.get_next()

	while (file_name != ""):
		var path = dir.get_current_dir() + "/" + file_name

		if dir.current_is_dir():
#			print("Found directory: %s" % path)
			var subDir = Directory.new()
			if subDir.open(path) == OK:
				subDir.list_dir_begin(true, false)
				directories.append(path)
				_add_dir_contents(subDir, files, directories)
			else:
				push_error("An error occurred when trying to access the path, %s" % subDir)
		else:
#			print("Found file: %s" % path)
			files.append(path)

		file_name = dir.get_next()

	dir.list_dir_end()
