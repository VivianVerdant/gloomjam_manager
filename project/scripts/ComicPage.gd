class_name ComicPage
extends Resource

var type = ComicPage

var attributes: Dictionary = {
	"id": "",
	"page_type": "paginated",
	"page_length": int(1),
	"title": {},
	"image_filename": {},
	"author_comment": {}
}

var original_id: String = attributes.id

var raw_text: String

var dirty: bool = false
var flagged_for_deletion: bool = false

func _init(dict: Dictionary) -> void:
	for key in dict.keys():
		if self.attributes[key] != null:
			self.attributes[key] = dict[key]	

func to_dict() -> Dictionary:
	return attributes

func write_to_filesystem(dir: DirAccess):
	# check if folder exists, create it if not
	if not dir.dir_exists(attributes.id):
		dir.make_dir(attributes.id)
	dir.change_dir(attributes.id)
	
	for lang in attributes.image_filename.keys():
		
		var path: String = attributes.image_filename.get(lang)
		
		attributes.image_filename.lang = to_relative_path(path)
		var filetype: String = path.get_extension()
		if attributes.page_length == 1:
			var new_name = attributes.id + "_" + lang + "." + filetype
			copy_file_to_folder(dir, path, new_name)
			
		else:
			for i in attributes.page_length:
				var splits = path.split(".")[0].get_file().split("_")
				var figures = splits[-1].length()
				var source_name = path.left(-(figures + filetype.length() + 1)) + str(i + 1).pad_zeros(figures) + "." + filetype
				var new_name = attributes.id + "_" + lang + "_" + str(i + 1).pad_zeros(3) + "." + filetype
				copy_file_to_folder(dir, source_name, new_name)

func to_relative_path(path: String) -> String:
	if path.is_relative_path():
		return path
	else:
		return path.trim_prefix(GlobalSettings.last_db_path)

func copy_file_to_folder(dir: DirAccess, in_path: String, new_name: String) -> void:
	var result = dir.copy(in_path, dir.get_current_dir().path_join(new_name))
	Console.print(error_string(result))
