class_name ComicPage
extends Resource

var type = ComicPage
var original_id: String
var id: String:
	set(value):
		id = value
		dirty = true

var raw_text: String

var languages: Array
var title: Dictionary:
	set(value):
		title = value
		dirty = true

var image_filename: Dictionary:
	set(value):
		image_filename = value
		dirty = true

var author_comment: Dictionary:
	set(value):
		author_comment = value
		dirty = true

var dirty: bool
var flagged_for_deletion: bool = false

func _init(dict: Dictionary) -> void:
	id = dict.id
	original_id = dict.id
	if dict.has("languages"):
		languages = dict.languages
	else:
		languages =  GlobalSettings.default_languages
	
	if dict.has("title"):
		title = dict.title
	else:
		var split = id.split("pg")
		for lang in languages:
			title[lang] = "Page " + var_to_str(int(id.split("pg")[-1]))
	
	if dict.has("image"):
		image_filename = dict.image
		
	if dict.has("author_comment"):
		author_comment = dict.author_comment
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func to_dict() -> Dictionary:
	var dict: Dictionary = {
		"id": id,
		"languages": languages,
		"title": title,
		"image": image_filename,
		"author_comment": author_comment
	}
	return dict

func add_language(lang: String):
	if lang in languages:
		return
	
	languages.append(lang)
	title[lang] = "" if title.keys().is_empty() else title[title.keys()[0]]
	image_filename[lang] = "" if image_filename.keys().is_empty() else image_filename[image_filename.keys()[0]]
	author_comment[lang] = "" if author_comment.keys().is_empty() else author_comment[author_comment.keys()[0]]
	
func delete_language(lang: String):
	if lang not in languages:
		return
	
	languages.erase(lang)
	if title.has(lang):
		title.erase(lang)
	if image_filename.has(lang):
		image_filename.erase(lang)
	if author_comment.has(lang):
		author_comment.erase(lang)

func write_to_filesystem(dir: DirAccess):
	# check if folder exists, create it if not
	if not dir.dir_exists(id):
		dir.make_dir(id)
	dir.change_dir(id)

	for lang in image_filename.keys():
		if image_filename.get(lang).is_relative_path():
			return
		
		var filetype: String = image_filename.get(lang).get_extension()
		var destination: String = dir.get_current_dir().path_join(id + "_" + lang + "." + filetype)
		Console.print("Source:", image_filename.get(lang))
		Console.print("Destination:", destination)
		
		var result = dir.copy(image_filename.get(lang), destination)
		Console.print(error_string(result))
		
		var relative_path: String = destination.trim_prefix(GlobalSettings.last_db_path)
		if OS.get_name() == "Windows":
			relative_path = relative_path.substr(2, -1)
		else:
			relative_path = relative_path.substr(1, -1)
		image_filename.set(lang, relative_path)
		Console.print("Relative path:", relative_path)
