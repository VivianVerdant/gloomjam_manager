extends PanelContainer

var comic: ComicDatabase: set = on_comic_updated
@onready var dropdown = %page_type_selector
@onready var language_list_container = %language_list_container
@onready var language_container = %language_container

signal panel_updated(comic)

func on_comic_updated(value):
	comic = value
	update_panel()

func update_panel():
	match comic.attributes.page_type:
		"paginated":
			dropdown.select(0)
		"scrolling":
			dropdown.select(1)
	
	for lang in comic.attributes.languages:
		if lang == "en":
			continue
			
		var copy = language_container.duplicate()
		copy.get_child(0).text = lang
		copy.get_child(0).placeholder_text = ""
		copy.get_child(1).show()
		language_list_container.add_child(copy)
	
	%main_site_title.text		= str(comic.attributes.title)
	%main_site_author.text		= str(comic.attributes.author)
	%main_site_address.text		= str(comic.attributes.link)
	%main_site_fileroot.text	= str(comic.attributes.fileroot)
	if str(comic.attributes.fileroot) == "":
		%main_site_fileroot.placeholder_text = str(comic.attributes.link)
	
	match comic.attributes.rss_content:
		"thumb":
			%rss_feed_content.selected = 0
		"image":
			%rss_feed_content.selected = 1
		_:
			%rss_feed_content.selected = 2
	
func _on_page_type_selector_item_selected(index: int) -> void:
	match index:
		0:
			comic.attributes.page_type = "paginated"
		1:
			comic.attributes.page_type = "scrolling"
	
	panel_updated.emit(comic)

func update_languages() -> void:
	var languages: PackedStringArray = []
	if language_list_container.get_child(0).get_child(0).text == "":
		languages.append("en")
	
	for node in language_list_container.get_children():
		var text: String = node.get_child(0).text
		text = text.replace(" ", "")
		node.get_child(0).text = text
		if text != "":
			languages.append(text)
	
	comic.attributes.languages = languages

func _on_add_language_button_up() -> void:
	var copy = language_container.duplicate()
	copy.get_child(0).text = ""
	copy.get_child(0).placeholder_text = ""
	copy.get_child(1).show()
	language_list_container.add_child(copy)

func _on_delete_language_button_up() -> void:
	call_deferred("update_languages")
	
func _on_language_line_edit_editing_toggled(toggled_on: bool) -> void:
	if not toggled_on:
		update_languages()

func _on_main_site_title_text_changed(new_text: String) -> void:
	comic.attributes.title = new_text
	panel_updated.emit(comic)

func _on_main_site_author_text_changed(new_text: String) -> void:
	comic.attributes.author = new_text
	panel_updated.emit(comic)

func _on_main_site_address_text_changed(new_text: String) -> void:
	comic.attributes.link = new_text
	%main_site_fileroot.placeholder_text = new_text
	if new_text == "":
		%main_site_fileroot.placeholder_text = "https://example.com"
		
	panel_updated.emit(comic)

func _on_main_site_fileroot_text_changed(new_text: String) -> void:
	comic.attributes.fileroot = new_text
	panel_updated.emit(comic)

func _on_rss_feed_content_item_selected(index: int) -> void:
	match index:
		0:
			comic.attributes.rss_content = "thumb"
		1:
			comic.attributes.rss_content = "image"
		2:
			comic.attributes.rss_content = "link"
	panel_updated.emit(comic)
