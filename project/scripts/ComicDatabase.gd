class_name ComicDatabase
extends GloomjamDatabase

const type = ComicDatabase

var attributes: Dictionary = {
	"id": "comic",
	"page_type": "paginated",
	"languages": ["en"],
	"title": "Comic",
	"author": "Author",
	"link": "https://example.com",
	"fileroot": "",
	"export_subdirectory": "",
	"rss_content": "link",
	"chapters": []
}

var dirty = false

func _init(dict: Dictionary) -> void:
	for key in dict.keys():
		if self.attributes.has(key):
			self.attributes[key] = dict[key]
	for i in attributes.chapters.size():
		var obj = attributes.chapters.pop_front()
		match typeof(obj):
			TYPE_DICTIONARY:
				attributes.chapters.push_back(ComicChapter.new(obj))
			_:
				pass

func get_page_by_id(pid: String):
	for chapter: ComicChapter in attributes.chapters:
		if chapter.get_page_by_id(pid):
			return chapter.get_page_by_id(pid)
	return false

func get_chapter_by_id(cid: String):
	for chapter: ComicChapter in attributes.chapters:
		if chapter.attributes.id == cid:
			return chapter
	return false

func get_chapter_by_page_id(cid: String):
	for chapter: ComicChapter in attributes.chapters:
		for page: ComicPage in chapter.attributes.pages:
			if page.attributes.id == cid:
				return chapter
	return false

func get_resource_by_id(rid: String):
	if attributes.id == rid:
		return self
	
	if get_chapter_by_id(rid):
		return get_chapter_by_id(rid)
		
	if get_page_by_id(rid):
		return get_page_by_id(rid)
		
	return false

func add_chapter(chapter: ComicChapter) -> ComicChapter:
	attributes.chapters.append(chapter)
	return chapter
	
func to_dict(for_export: bool = false) -> Dictionary:
	var dict = attributes.duplicate(true)
	for chapter in dict.chapters:
		var ch: ComicChapter = dict.chapters.pop_front()
		dict.chapters.append(ch.to_dict(for_export))
	return dict

func move_item(item, target, mode):
	match item.type:
		ComicChapter:
			var chapter_position = attributes.chapters.find(item)
			var _pop_chapter = attributes.chapters.pop_at(chapter_position)
			
			var target_position = attributes.chapters.find(target)
			match mode:
				'before':
					attributes.chapters.insert(target_position, item)
				'after':
					attributes.chapters.insert(target_position + 1, item)
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

func queue_export(path: String):
	var root_folder = path.path_join(attributes.id)
	for chapter: ComicChapter in attributes.chapters:
		chapter.queue_export(root_folder)
	pass
