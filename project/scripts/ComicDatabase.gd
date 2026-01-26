class_name ComicDatabase
extends Resource

var id = "Comic"
var chapters: Array = []

func get_page_by_id(pid: String):
	for chapter in chapters:
		if chapter.get_page_by_id(pid):
			return chapter.get_page_by_id(pid)
	return false

func get_chapter_by_id(cid: String):
	for chapter: ComicChapter in chapters:
		if chapter.id == cid:
			return chapter
	return false

func get_resource_by_id(rid: String):
	if get_chapter_by_id(rid):
		return get_chapter_by_id(rid)
		
	if get_page_by_id(rid):
		return get_page_by_id(rid)
		
	return false

func add_chapter(chapter: ComicChapter) -> ComicChapter:
	chapters.append(chapter)
	return chapter
	
func to_dict() -> Dictionary:
	var chapters_array: Array = []
	for chapter: ComicChapter in chapters:
		chapters_array.append(chapter.to_dict())
	var dict: Dictionary = {
		"id": id,
		"chapters": chapters_array
	}
	return dict

func _init(dict: Dictionary) -> void:
	if dict.has("id"):
		id = dict.id
	if dict.has("chapters"):
		for chapter in dict.chapters:
			chapters.append(ComicChapter.new(chapter))


func move_item(item, target, mode):
	match item.type:
		ComicChapter:
			pass
		ComicPage:
			pass
