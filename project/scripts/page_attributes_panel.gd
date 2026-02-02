extends PanelContainer

var page: ComicPage: set = on_page_updated
var language_code: String: set = on_language_code_updated
var title: String: set = on_title_updated
var image_filename: String: set = on_image_filename_updated
var author_comment: String: set = on_author_comment_updated

signal panel_updated(page, lang)

@onready var raw_text_node = %raw_text
var raw_text: String: set = on_update_raw_text

func on_update_raw_text(value):
	raw_text = value
	raw_text_node.text =  value

func _on_open_page_image_button_button_up() -> void:
	%open_page_image_file_dialog.show()

func on_language_code_updated(value):
	language_code = value
	%language_code_label.text = value

func on_page_updated(value):
	page = value
	update_panel()

func on_title_updated(value):
	title = value
	update_page()

func on_image_filename_updated(value):
	image_filename = value
	update_page()
	
func on_author_comment_updated(value):
	author_comment = value
	update_page()
	
func update_page():
	page.title[language_code] = title
	page.image_filename[language_code] = image_filename
	page.author_comment[language_code] = author_comment
	
	if language_code == page.languages[0]:
		emit_signal("panel_updated", page, language_code)
	
func update_panel():
	if page.author_comment.has(language_code):
		%author_comment_text.text = page.author_comment[language_code]
	if page.title.has(language_code):
		%page_title_text.text = page.title[language_code]

func _on_accept_delete_button_up() -> void:
	page.delete_language(language_code)

func _on_page_title_text_changed(new_text: String) -> void:
	title = new_text

func _on_author_comment_text_changed() -> void:
	author_comment = %author_comment_text.text
