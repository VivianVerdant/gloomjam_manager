class_name ComicPage
extends Resource

var type = ComicPage

var attributes: Dictionary = {
	"id": "",
	"pubDate": Time.get_datetime_string_from_system(),
	"page_type": "paginated",
	"page_length": int(1),
	"thumbnail": "",
	"title": {},
	"image_filename": {},
	"author_comment": {}
}

var original_id: String = attributes.id

var raw_text: String

var flagged_for_deletion: bool = false

func _init(dict: Dictionary) -> void:
	for key in dict.keys():
		if self.attributes.has(key):
			self.attributes[key] = dict[key]
			
	if typeof(attributes.page_length) == TYPE_FLOAT:
		attributes.page_length = attributes.page_length as int

func to_dict() -> Dictionary:
	return attributes

func write_to_filesystem(dir: DirAccess):
	# check if folder exists, create it if not
	if not dir.dir_exists(attributes.id):
		dir.make_dir(attributes.id)
	dir.change_dir(attributes.id)
	
	var new_dir = to_relative_path(dir.get_current_dir())
	var new_path
	
	if attributes.thumbnail != "" and attributes.thumbnail.is_absolute_path():
		var path: String = attributes.thumbnail
		var filetype: String = path.get_extension()
		var new_name = attributes.id + "_thumb." + filetype
		#copy_file_to_folder(dir, path, new_name)
		new_path = new_dir.path_join(new_name)
		queue_file_copy(path, new_path)
		#self.attributes.thumbnail = new_path
	
	for lang in attributes.image_filename.keys():
		var path: String = attributes.image_filename.get(lang)
		
		if path == "" or path.is_relative_path():
			continue
		
		var filetype: String = path.get_extension()
		if attributes.page_length == 1:
			var new_name = attributes.id + "_" + lang + "." + filetype
			#copy_file_to_folder(dir, path, new_name)
			new_path = new_dir.path_join(new_name)
			queue_file_copy(path, new_path)
			#self.attributes.image_filename[lang] = new_path
			
		else:
			var new_name
			for i in attributes.page_length:
				var splits = path.split(".")[0].get_file().split("_")
				var figures = splits[-1].length()
				var source_name = path.left(-(figures + filetype.length() + 1)) + str(i + 1).pad_zeros(figures) + "." + filetype
				new_name = attributes.id + "_" + lang + "_" + str(i + 1).pad_zeros(3) + "." + filetype
				new_path = new_dir.path_join(new_name)
				#copy_file_to_folder(dir, source_name, new_name)
				queue_file_copy(source_name, new_path)
				
			new_name = attributes.id + "_" + lang + "_" + str(1).pad_zeros(3) + "." + filetype
			new_path = new_dir.path_join(new_name)
			#self.attributes.image_filename[lang] = new_path

func to_relative_path(path: String) -> String:
	if path.is_relative_path():
		return path
	else:
		return path.trim_prefix(GlobalSettings.export_path).lstrip("\\/")

func copy_file_to_folder(dir: DirAccess, in_path: String, new_name: String) -> void:
	var result = dir.copy(in_path, dir.get_current_dir().path_join(new_name))
	Console.print(error_string(result))
	
func queue_file_copy(source: String, destination: String):
	GlobalSettings.queued_file_changes.push_back(QueuedFileChange.new(source, destination, self))

func make_relative(source_path, destination_path) -> Error:
	if attributes.thumbnail == source_path:
		attributes.thumbnail = destination_path
		return Error.OK
	for key in attributes.image_filename.keys():
		if attributes.image_filename[key] == source_path:
			attributes.image_filename[key] = destination_path
			return Error.OK
	return Error.ERR_DOES_NOT_EXIST
