class_name ComicPage
extends Resource

var type = ComicPage

var attributes: Dictionary = {
	"id": "",
	"page_type": "paginated",
	"title": {},
	"image_filename": {},
	"author_comment": {}
}

#var id: String:
	#set(value):
		#id = value
		#dirty = true
var original_id: String = attributes.id

var raw_text: String

#var languages: Array = GlobalSettings.default_languages
#var title: Dictionary = {"en":""}:
	#set(value):
		#title = value
		#dirty = true

#var image_filename: Dictionary = {"en":""}:
	#set(value):
		#image_filename = value
		#dirty = true

#var author_comment: Dictionary = {"en":""}:
	#set(value):
		#author_comment = value
		#dirty = true

#var page_type: String = "paginated"

var dirty: bool = false
var flagged_for_deletion: bool = false

func _init(dict: Dictionary) -> void:
	for key in dict.keys():
		if self.attributes[key] != null:
			self.attributes[key] = dict[key]
	#dict.get_or_add("foo","bar")
	#var props = self.get_property_list()
	#var prop_names: PackedStringArray
	#for prop in props:
		#prop_names.push_back(prop.name)
	#for key in dict.keys():
		#if prop_names.has(key):
			#self.set(key, dict.get(key))
	#return
		
	#id = dict.id
	#original_id = dict.id
	#if dict.has("languages"):
		#languages = dict.languages
	#else:
		#languages =  GlobalSettings.default_languages
	#
	#if dict.has("title"):
		#title = dict.title
	#else:
		#var split = id.split("pg")
		#for lang in languages:
			#title[lang] = "Page " + var_to_str(int(id.split("pg")[-1]))
	#
	#if dict.has("image"):
		#image_filename = dict.image
		#
	#if dict.has("author_comment"):
		#author_comment = dict.author_comment
	

func to_dict() -> Dictionary:
	return attributes

#func add_language(lang: String):
	#if lang in attributes.languages:
		#return
	#
	#attributes.languages.append(lang)
	#attributes.title[lang] = "" if attributes.title.keys().is_empty() else attributes.title[attributes.title.keys()[0]]
	#attributes.image_filename[lang] = "" if attributes.image_filename.keys().is_empty() else attributes.image_filename[attributes.image_filename.keys()[0]]
	#attributes.author_comment[lang] = "" if attributes.author_comment.keys().is_empty() else attributes.author_comment[attributes.author_comment.keys()[0]]
	#
#func delete_language(lang: String):
	#if lang not in attributes.languages:
		#return
	#
	#attributes.languages.erase(lang)
	#if attributes.title.has(lang):
		#attributes.title.erase(lang)
	#if attributes.image_filename.has(lang):
		#attributes.image_filename.erase(lang)
	#if attributes.author_comment.has(lang):
		#attributes.author_comment.erase(lang)

func write_to_filesystem(dir: DirAccess):
	# check if folder exists, create it if not
	if not dir.dir_exists(attributes.id):
		dir.make_dir(attributes.id)
	dir.change_dir(attributes.id)

	for lang in attributes.image_filename.keys():
		if attributes.image_filename.get(lang).is_relative_path():
			return
		
		var filetype: String = attributes.image_filename.get(lang).get_extension()
		var destination: String = dir.get_current_dir().path_join(attributes.id + "_" + lang + "." + filetype)
		Console.print("Source:", attributes.image_filename.get(lang))
		Console.print("Destination:", destination)
		
		var result = dir.copy(attributes.image_filename.get(lang), destination)
		Console.print(error_string(result))
		
		var relative_path: String = destination.trim_prefix(GlobalSettings.last_db_path)
		if OS.get_name() == "Windows":
			relative_path = relative_path.substr(2, -1)
		else:
			relative_path = relative_path.substr(1, -1)
		attributes.image_filename.set(lang, relative_path)
		Console.print("Relative path:", relative_path)
