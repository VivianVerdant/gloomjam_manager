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
	if dict.has("title"):
		title = dict.title
	else:
		var split = id.split("pg")
		for lang in GlobalSettings.default_languages:
			title[lang] = "Page " + var_to_str(int(id.split("pg")[-1]))
	if dict.has("languages"):
		languages = dict.languages
	else:
		languages =  GlobalSettings.default_languages
	
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
