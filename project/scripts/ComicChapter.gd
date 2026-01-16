class_name ComicChapter
extends Resource

var type = ComicChapter
var id: String
var pages: Dictionary

var title: String

func _init(cid) -> void:
	id = cid
	title = "Chapter " + var_to_str(int(cid))

func get_page_by_id(pid: String):
	if pages.has(pid):
		return pages[pid]
	
	return false
	
func add_page(page: ComicPage) -> ComicPage:
	pages[page.id] = page
	return page
