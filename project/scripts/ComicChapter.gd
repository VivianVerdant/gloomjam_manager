class_name ComicChapter
extends Resource

var type: = ComicChapter

var attributes: Dictionary = {
	"id": "",
	"title": {},
	"pages": []
}

var original_id: String = attributes.id

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

func to_dict(for_export: bool = false) -> Dictionary:
	var dict: Dictionary = attributes.duplicate(true)
	for page in dict.pages:
		var pg: ComicPage = dict.pages.pop_front()
		if not for_export:
			dict.pages.append(pg.to_dict())
			continue
		if Time.get_unix_time_from_datetime_string(pg.attributes.pub_date) < Time.get_unix_time_from_system():
			dict.pages.append(pg.to_dict())
	return dict
	
func queue_export(path: String) -> void:
	# check if folder exists, create it if not
	var root_folder: String = path.path_join(attributes.id)

	for page: ComicPage in attributes.pages:
		page.queue_export(root_folder)
		
