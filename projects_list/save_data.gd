extends Resource

class_name SaveData

const PATH = "user://save"

@export var project_list: Resource

func save_data():
	ResourceSaver.save(self, get_save_path())
	

static func save_exists():
	return ResourceLoader.exists(get_save_path())
	
	
static func load_data():
	var save_path = get_save_path()
	if not ResourceLoader.has_cached(save_path):
		return ResourceLoader.load(save_path, "", ResourceLoader.CACHE_MODE_IGNORE)
		
	var f = FileAccess.open(save_path, FileAccess.READ)
	if f != OK:
		print("Cannot read file")
		return null


	var data = f.get_as_text()
	f.close()
	
	var tmp_file_path = make_random_path()
	while ResourceLoader.has_cached(tmp_file_path):
		tmp_file_path = make_random_path()
	f = FileAccess.open(tmp_file_path, FileAccess.WRITE)
	if f != OK:
		print("Cannot write file")
		return null
		
	f.store_string(data)
	f.close()
	
	var save = ResourceLoader.load(tmp_file_path, "", ResourceLoader.CACHE_MODE_IGNORE)
	save.take_over_path(save_path)
	
	#FIXME: Any errors with removing temp paths for saves, Look here
	# I wasnt sure what directory to open due to api changes.
	var directory = DirAccess.open(tmp_file_path)
	directory.remove(tmp_file_path)
	return save
	
	
static func make_random_path() -> String:
	return "user://temp_file_" + str(randi()) + ".tres"
	
	
static func get_save_path() -> String:
	var extension := ".tres" if OS.is_debug_build() else ".res"
	return PATH + extension
