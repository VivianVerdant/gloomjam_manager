class_name ComicDatabase
extends Resource

var type = ComicDatabase

var attributes: Dictionary = {
	"id": "comic",
	"page_type": "paginated",
	"languages": ["en"],
	"chapters": []
}

var dirty = false

func _init(dict: Dictionary) -> void:
	for key in dict.keys():
		if self.attributes[key] != null:
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
	
func to_dict() -> Dictionary:
	var dict = attributes.duplicate(true)
	for chapter in dict.chapters:
		var ch: ComicChapter = dict.chapters.pop_front()
		dict.chapters.append(ch.to_dict())
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

func write_to_filesystem(current_database_file: String):
	var root_folder = current_database_file.get_base_dir()
	var dir = DirAccess.open(root_folder)
	
	for chapter: ComicChapter in attributes.chapters:
		dir.change_dir(root_folder)
		chapter.write_to_filesystem(dir)
	pass
