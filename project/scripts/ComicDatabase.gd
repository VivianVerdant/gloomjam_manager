class_name ComicDatabase
extends Resource

var id = "comic"
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

func get_chapter_by_page_id(cid: String):
	for chapter: ComicChapter in chapters:
		for page: ComicPage in chapter.pages:
			if page.id == cid:
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
			var chapter_position = chapters.find(item)
			var _pop_chapter = chapters.pop_at(chapter_position)
			
			var target_position = chapters.find(target)
			match mode:
				'before':
					chapters.insert(target_position, item)
				'after':
					chapters.insert(target_position + 1, item)
			Console.print(self)
		
		ComicPage:
			var page_chapter = get_chapter_by_page_id(item.id)
			var page_position = page_chapter.pages.find(item)
			var _pop_page = page_chapter.pages.pop_at(page_position)
			
			var target_chapter = get_chapter_by_page_id(target.id)
			var target_position = target_chapter.pages.find(target)
			match mode:
				'before':
					target_chapter.pages.insert(target_position, item)
				'after':
					target_chapter.pages.insert(target_position + 1, item)
			Console.print(self)
