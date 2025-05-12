extends Control

const PATH = "user://saved_projects.json"

var projects_list = []
var project_selected


signal change_scene_to_file(project_name, path)

func _ready() -> void:
	load_data()



func save_data():
	var f = FileAccess.open(PATH, FileAccess.WRITE)
	f.store_line(JSON.stringify(projects_list))
	f.close()
	
	
func load_data():
	if not FileAccess.file_exists(PATH):
		save_data()
		return
	
	var f = FileAccess.open(PATH, FileAccess.READ)
	var test_json_conv = JSON.new()
	test_json_conv.parse(f.get_as_text())
	projects_list = test_json_conv.get_data()
	f.close()
	
	#FIXME: any issues with removing projects from the project list, this is probably the culprite.
	var dir = DirAccess.open(PATH)
	if dir != null:
		for i in range(projects_list.size(), 0, -1):
			if not dir.dir_exists(projects_list[i-1]["path"]):
				projects_list.remove_at(i-1)
	
	save_data()
	
	
	var icon = load("res://love_icon.png")
	for project in projects_list:
		$HSplitContainer/Panel/ItemList.add_item(project["project_name"] + "(Location: " + project["path"] + ")", icon)
	
	

# Create new project
func _on_NewProjectButton_pressed() -> void:
	$AcceptDialog.popup()
	

func _on_ChoosePathButton_pressed() -> void:
	$NewProjectDialog.popup_centered()
	

func _on_NewProjectDialog_dir_selected(dir: String) -> void:
	$AcceptDialog/GridContainer/Path3D.text = dir
	if not check_blank_folder(dir):
		$AcceptDialog/VBoxContainer/Warning3.show()
	else:
		$AcceptDialog/VBoxContainer/Warning3.hide()


func _on_CreateProjectButton_pressed() -> void:
	if $AcceptDialog/GridContainer/ProjectName.text == "":
		$AcceptDialog/VBoxContainer/Warning1.show()
	else:
		$AcceptDialog/VBoxContainer/Warning1.hide()
		
	if $AcceptDialog/GridContainer/Path3D.text == "":
		$AcceptDialog/VBoxContainer/Warning2.show()
	else:
		$AcceptDialog/VBoxContainer/Warning2.hide()
		add_project($AcceptDialog/GridContainer/ProjectName.text, $AcceptDialog/GridContainer/Path3D.text)
		$AcceptDialog.hide()
#		$AcceptDialog/VBoxContainer/Warning3.hide()


func check_blank_folder(path):
	print(path)
	var dir = DirAccess.open(path)
	if dir == OK:
		dir.list_dir_begin() # TODOConverter3To4 fill missing arguments https://github.com/godotengine/godot/pull/40547
		var file_name = dir.get_next()
		if file_name != "":
			print(file_name)
			return false
			
		return true
	else:
		print("Cannot open the folder")
				

func add_project(project_name, path):
#	$HSplitContainer/Panel/ItemList.clear()
	var logo = load("res://love_icon.png")
	projects_list.append({
		"project_name" : project_name,
		"path" : path
	})
	save_data()
	$HSplitContainer/Panel/ItemList.add_item(project_name + " (Location: " + path + ")", logo)
	


# Open existing project
func _on_OpenProjectButton_pressed() -> void:
	$OpenProjectWindow.popup()


func _on_OpenProject_ChoosePathButton_pressed() -> void:
	$OpenProjectDialog.popup()


func _on_OpenProjectDialog_file_selected(path: String) -> void:
	$OpenProjectWindow/GridContainer/Path3D.text = path.get_base_dir()
	$OpenProjectWindow/VBoxContainer/Warning3.hide()


func _on_Confirm_OpenProjectButton_pressed() -> void:
	if $OpenProjectWindow/GridContainer/ProjectName.text == "":
		$OpenProjectWindow/VBoxContainer/Warning1.show()
	else:
		$OpenProjectWindow/VBoxContainer/Warning1.hide()
		
	if $OpenProjectWindow/GridContainer/Path3D.text == "":
		$OpenProjectWindow/VBoxContainer/Warning2.show()
	else:
		$OpenProjectWindow/VBoxContainer/Warning2.hide()
		add_project($OpenProjectWindow/GridContainer/ProjectName.text, $OpenProjectWindow/GridContainer/Path3D.text)
		$OpenProjectWindow.hide()


# Delete project
func _on_ItemList_item_selected(index: int) -> void:
	$HSplitContainer/ColorRect/VBoxContainer/DeleteProjectButton.disabled = false
	project_selected = index
	Global.project_path = projects_list[project_selected]["path"]


func _on_ItemList_nothing_selected() -> void:
	$HSplitContainer/ColorRect/VBoxContainer/DeleteProjectButton.disabled = true
	$HSplitContainer/Panel/ItemList.deselect_all()


func _on_DeleteProjectButton_pressed() -> void:
	$DeleteConfirmationDialog.popup()
	$DeleteConfirmationDialog.dialog_text = "Are you sure you want to delete " + projects_list[project_selected]["project_name"]
	

func _on_DeleteConfirmationDialog_confirmed() -> void:
	projects_list.remove_at(project_selected)
	save_data()
	$HSplitContainer/Panel/ItemList.clear()
	load_data()
	


# Open up a project, open code editor
func _on_ItemList_item_activated(index: int) -> void:
	emit_signal("change_scene_to_file", projects_list[project_selected]["project_name"], projects_list[project_selected]["path"])
