extends Node

const VALID_IMAGETYPES: PackedStringArray = ["bmp","dds","ktx","exr","hdr","jpg","jpeg","png","tga","svg","webp"]

var last_db_path: String:
	set(value):
		last_db_path = value
		save_file()
		
var last_db_name: String:
	set(value):
		last_db_name = value
		save_file()
		
var bg_color: String:
	set(value):
		bg_color = value
		save_file()
		
var default_settings = {
		"last_db_path": "",
		"last_db_name": "db.json",
		"bg_color": "4d4d4d"
	}

@onready var base_dir = "res://" if OS.has_feature("editor") else OS.get_executable_path().get_base_dir()

func load_settings() -> void:
	var settings_obj = load_file()
	
	if not settings_obj:
		Console.print("Creating settings file with default values")
		settings_obj = default_settings
	
	for key in default_settings.keys():
		if not settings_obj.has(key):
			settings_obj.set(key, default_settings.get(key))
	
	last_db_path = settings_obj.last_db_path
	last_db_name = settings_obj.last_db_name
	bg_color = settings_obj.bg_color
	Console.print("loaded settings:", settings_obj)
	save_file()
	
func save_file():
	var settings_object = {
		"last_db_path": last_db_path,
		"last_db_name": last_db_name,
		"bg_color": bg_color
	}
	var settings_string = JSON.stringify(settings_object, "\t")
	var file = FileAccess.open(base_dir + "\\settings.ini", FileAccess.WRITE)
	file.store_string(settings_string)
	return file

func load_file():
	var file = FileAccess.open(base_dir + "\\settings.ini", FileAccess.READ)
	if not file:
		Console.print("No existing settings file found")
		return false
	Console.print("Found existing settings file at", file.get_path(), "loading")
	var settings_string = file.get_as_text()
	var json = JSON.new()
	var error = json.parse(settings_string)
	var settings_obj: Dictionary
	if error == OK:
		if typeof(settings_obj) == TYPE_DICTIONARY:
			settings_obj = json.data
			Console.print("Successfully loaded settings file")
		else:
			Console.print("Unexpected data parsing settings.ini")
	else:
		Console.print("JSON Parse Error: ", json.get_error_message(), " in ", settings_string, " at line ", json.get_error_line())
		return false

	return settings_obj
