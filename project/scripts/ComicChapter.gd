class_name ComicChapter
extends Resource

var type: = ComicChapter

var attributes: Dictionary = {
	"id": "",
	"title": {},
	"pages": []
}

var original_id: String = attributes.id

var dirty: bool
var flagged_for_deletion: bool = false

func _init(dict: Dictionary) -> void:
	for key: Variant in dict.keys():
		if self.attributes.has(key):
			self.attributes[key] = dict[key]
	
	for i: int in attributes.pages.size():
		var obj: Variant = attributes.pages.pop_front()
		match typeof(obj):
			TYPE_DICTIONARY:
				attributes.pages.push_back(ComicPage.new(obj))
			_:
				pass

func get_page_by_id(pid: String) -> Variant:
	for page: ComicPage in attributes.pages:
		if page.attributes.id == pid:
			return page
	return false
	
func add_page(page: ComicPage) -> ComicPage:
	attributes.pages.append(page)
	return page

func to_dict() -> Dictionary:
	var dict: Dictionary = attributes.duplicate(true)
	for page in dict.pages:
		var pg = dict.pages.pop_front()
		dict.pages.append(pg.to_dict())
	return dict
	
func write_to_filesystem(dir: DirAccess) -> void:
	# check if folder exists, create it if not
	if not dir.dir_exists(attributes.id as String):
		dir.make_dir(attributes.id as String)
	dir.change_dir(attributes.id as String)
	var root_folder: String = dir.get_current_dir()

	for page: ComicPage in attributes.pages:
		dir.change_dir(root_folder)
		page.write_to_filesystem(dir)
		
