class_name ComicChapter
extends Resource

var type = ComicChapter

var attributes: Dictionary = {
	"id": "",
	"title": {},
	"pages": []
}

var original_id: String = attributes.id

#var id: String:
	#set(value):
		#id = value
		#dirty = true
		
#var pages: Array

#var languages: Array

#var title: Dictionary:
	#set(value):
		#title = value
		#dirty = true

var dirty: bool
var flagged_for_deletion: bool = false

func _init(dict: Dictionary) -> void:
	for key in dict.keys():
		if self.attributes[key] != null:
			self.attributes[key] = dict[key]
	
	for i in attributes.pages.size():
		var obj = attributes.pages.pop_front()
		match typeof(obj):
			TYPE_DICTIONARY:
				attributes.pages.push_back(ComicPage.new(obj))
			_:
				pass
	
	#attributes.id = dict.id
	#original_id = dict.id
	#if dict.has("languages"):
		#languages = dict.languages
	#else:
		#languages =  GlobalSettings.default_languages
	#if dict.has("title"):
		#attributes.title = dict.title
	#else:
		#for lang in languages:
			#title[lang] = "Chapter " + var_to_str(int(id))
	#if dict.has("pages"):
		#for page in dict.pages:
			#attributes.pages.append(ComicPage.new(page))

func get_page_by_id(pid: String):
	for page in attributes.pages:
		if page.attributes.id == pid:
			return page
	return false
	
func add_page(page: ComicPage) -> ComicPage:
	attributes.pages.append(page)
	return page

func to_dict() -> Dictionary:
	var dict = attributes.duplicate(true)
	for page in dict.pages:
		var pg: ComicPage = dict.pages.pop_front()
		dict.pages.append(pg.to_dict())
	return dict
	#var pages_array: Array = []
	#for page: ComicPage in pages:
		#pages_array.append(page.to_dict())
	#var dict: Dictionary = {
		#"id": id,
		#"title": title,
		#"pages": pages_array
	#}
	#return dict

#func add_language(lang: String):
	#if lang in attributes.languages:
		#return
	#
	#attributes.languages.append(lang)
	#attributes.title[lang] = "" if attributes.title.keys().is_empty() else attributes.title[attributes.title.keys()[0]]
	#
#func delete_language(lang: String):
	#if lang not in attributes.languages:
		#return
	#
	#attributes.languages.erase(lang)
	#if attributes.title.has(lang):
		#attributes.title.erase(lang)
		
func write_to_filesystem(dir: DirAccess):
	# check if folder exists, create it if not
	if not dir.dir_exists(attributes.id):
		dir.make_dir(attributes.id)
	dir.change_dir(attributes.id)
	var root_folder = dir.get_current_dir()

	for page: ComicPage in attributes.pages:
		dir.change_dir(root_folder)
		page.write_to_filesystem(dir)
		
