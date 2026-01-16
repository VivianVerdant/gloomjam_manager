class_name ComicDatabase
extends Resource

var chapters: Dictionary

func get_page_by_id(pid: String):
	for chapter in chapters:
		if chapters[chapter].get_page_by_id(pid):
			return chapters[chapter].get_page_by_id(pid)
	return false

func get_chapter_by_id(cid: String):
	if chapters.has(cid):
		return chapters[cid]
	return false

func get_resource_by_id(rid: String):
	if get_chapter_by_id(rid):
		return get_chapter_by_id(rid)
		
	if get_page_by_id(rid):
		return get_page_by_id(rid)
		
	return false

func add_chapter(chapter: ComicChapter) -> ComicChapter:
	chapters[chapter.id] = chapter
	return chapter
