class_name ComicPage
extends Resource

var type = ComicPage
var id: String
var raw_text: String

var languages: Array
var title: Dictionary
var image_filename: Dictionary
var author_comment: Dictionary

func _init(dict: Dictionary) -> void:
	id = dict.id
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
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func to_dict() -> Dictionary:
	var dict: Dictionary = {
		"id": id,
		"languages": languages,
		"title": title
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
