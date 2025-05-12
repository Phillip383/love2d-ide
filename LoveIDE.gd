extends Control


func _on_ProjectsList_change_scene(project_name, path) -> void:
	$ProjectsList.hide()
	var directory = DirAccess.open(Global.project_path)
	if directory == OK:
		directory.list_dir_begin() # TODOConverter3To4 fill missing arguments https://github.com/godotengine/godot/pull/40547
		
		if not directory.file_exists("main.lua"):
			directory.copy(OS.get_executable_path().get_base_dir() + "/template" + "/main.lua", Global.project_path + "/main.lua")
	var code_editor = preload("res://code_editor/code_editor.tscn").instantiate()
	self.add_child(code_editor)
	

