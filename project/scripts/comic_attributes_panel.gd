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
