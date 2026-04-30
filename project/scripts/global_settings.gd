extends Node

var default_languages: Array
var last_db_path: String
var last_db_name: String

var default_settings = {
		"default_languages": ["en"],
		"last_db_path": OS.get_executable_path(),
		"last_db_name": "db.json",
	}

@onready var base_dir = "res://" if OS.has_feature("editor") else OS.get_executable_path().get_base_dir()

func load_settings() -> void:
	var settings_obj = load_file()
	
	for key in default_settings.keys():
		if not settings_obj.has(key):
			settings_obj.set(key, default_settings.get(key))
	
	default_languages = settings_obj.default_languages
	last_db_path = settings_obj.last_db_path
	last_db_name = settings_obj.last_db_name
	save_file()
	
func save_file():
	var settings_object = {
		"default_languages": default_languages,
		"last_db_path": last_db_path,
		"last_db_name": last_db_name
	}
	var settings_string = JSON.stringify(settings_object, "\t")
	var file = FileAccess.open(base_dir + "\\settings.ini", FileAccess.WRITE)
	file.store_string(settings_string)
	return file

func load_file():
	var file = FileAccess.open(base_dir + "\\settings.ini", FileAccess.READ)
	if not file:
		return false
	var settings_string = file.get_as_text()
	var json = JSON.new()
	var error = json.parse(settings_string)
	var settings_obj: Dictionary
	if error == OK:
		settings_obj = json.data
		if typeof(settings_obj) == TYPE_DICTIONARY:
			Console.print(settings_obj)
		else:
			Console.print("Unexpected data")
	else:
		Console.print("JSON Parse Error: ", json.get_error_message(), " in ", settings_string, " at line ", json.get_error_line())
		return false

	return settings_obj
