extends PanelContainer

var page: ComicPage
var language_code: String: set = on_language_code_updated
var title: String: set = on_title_updated
var image_filename: String: set = on_image_filename_updated
var author_comment: String: set = on_author_comment_updated

@onready var raw_text_node = %raw_text
var raw_text: String: set = on_update_raw_text

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func on_update_raw_text(value):
	raw_text = value
	raw_text_node.text =  value

func _on_open_page_image_button_button_up() -> void:
	%open_page_image_file_dialog.show()

func on_language_code_updated(value):
	language_code = value
	%language_code_label.text = value

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
