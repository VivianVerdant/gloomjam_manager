class_name ComicChapter
extends Resource

var type = ComicChapter
var original_id: String
var id: String
var pages: Array

var languages: Array

var title: Dictionary

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
		for lang in languages:
			title[lang] = "Chapter " + var_to_str(int(id))
	if dict.has("pages"):
		for page in dict.pages:
			pages.append(ComicPage.new(page))

func get_page_by_id(pid: String):
	for page in pages:
		if page.id == pid:
			return page
	return false
	
func add_page(page: ComicPage) -> ComicPage:
	pages.append(page)
	return page

func to_dict() -> Dictionary:
	var pages_array: Array = []
	for page: ComicPage in pages:
		pages_array.append(page.to_dict())
	var dict: Dictionary = {
		"id": id,
		"title": title,
		"pages": pages_array
	}
	return dict

func add_language(lang: String):
	if lang in languages:
		return
	
	languages.append(lang)
	title[lang] = "" if title.keys().is_empty() else title[title.keys()[0]]
	
func delete_language(lang: String):
	if lang not in languages:
		return
	
	languages.erase(lang)
	if title.has(lang):
		title.erase(lang)
