class_name ComicChapter
extends Resource

var type = ComicChapter
var id: String
var pages: Array

var title: Dictionary

func _init(dict: Dictionary) -> void:
	id = dict.id
	if dict.has("title"):
		title = dict.title
	else:
		for lang in GlobalSettings.default_languages:
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
