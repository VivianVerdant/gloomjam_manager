extends PanelContainer

var page: ComicPage: set = on_page_updated
var language_code: String: set = on_language_code_updated
var title: String: set = on_title_updated
var author_comment: String: set = on_author_comment_updated
var image_filename: String: set = on_image_filename_updated

signal panel_updated(page, lang)

#TODO: for some reason the comments are getting deleted if it tries to save over existing text?
# it's only on the SECOND time viewing the page that it deletes its?

func _ready() -> void:
	_on_background_color_picker_color_changed(GlobalSettings.bg_color)
	
	%image_drop_container.show()
	%image_preview_container.hide()
	%delete_page_image_button.hide()

func on_file_dropped(file_path: String):
	if not file_path:
		return
		
	var extension = file_path.rsplit(".")[-1]
	if (extension in GlobalSettings.VALID_IMAGETYPES):
		print(file_path)
		image_filename = file_path

func _on_open_page_image_button_button_up() -> void:
	if GlobalSettings.last_opened_image_location != "":
		%open_image_file_dialog.current_dir = GlobalSettings.last_opened_image_location
	elif GlobalSettings.export_path != "":
		%open_image_file_dialog.current_dir = GlobalSettings.export_path
	else:
		%open_image_file_dialog.current_dir = GlobalSettings.last_db.get_base_dir()
	%open_image_file_dialog.show()

func on_language_code_updated(value):
	language_code = value
	%language_code_label.text = value

func on_page_updated(value):
	page = value
	if page.attributes.title.has(language_code):
		title = page.attributes.title[language_code]
		
	if page.attributes.image_filename.has(language_code):
		image_filename = page.attributes.image_filename[language_code]
		
	if page.attributes.author_comment.has(language_code):
		author_comment = page.attributes.author_comment[language_code]
	
	update_panel()

func on_title_updated(value):
	title = value
	call_deferred("update_page")

func on_image_filename_updated(value):
	image_filename = value
	
	if value == "":
		%image_drop_container.show()
		%image_preview_container.hide()
		%page_image.texture = null
		%delete_page_image_button.hide()
	else:
		if image_filename.is_relative_path():
			value = GlobalSettings.export_path.path_join(image_filename)
		%image_drop_container.hide()
		%image_preview_container.show()
		%delete_page_image_button.show()
		if not FileAccess.file_exists(value):
			Console.warn("!Warning: File does not exist at:", value)
			return
		var image = Image.load_from_file(value)
		var texture = ImageTexture.create_from_image(image)
		%page_image.texture = texture
	call_deferred("update_page")
	
func on_author_comment_updated(value):
	author_comment = value
	call_deferred("update_page")
	
func update_page():
	page.attributes.title[language_code] = title
	page.attributes.image_filename[language_code] = image_filename
	page.attributes.author_comment[language_code] = author_comment #this is where it's breaking, comment hasn't been loaded in yet, why?
	
	emit_signal("panel_updated", page, language_code)
	
func update_panel():
	if page.attributes.author_comment.has(language_code):
		%author_comment_text.text = page.attributes.author_comment[language_code]
	if page.attributes.title.has(language_code):
		%page_title_text.text = page.attributes.title[language_code]
	if page.attributes.image_filename.has(language_code):
		_on_open_image_file_dialog_file_selected(page.attributes.image_filename[language_code])

func _on_accept_delete_button_up() -> void:
	page.delete_language(language_code)

func _on_page_title_text_changed(new_text: String) -> void:
	title = new_text

func _on_author_comment_text_changed() -> void:
	author_comment = %author_comment_text.text

func _on_delete_page_image_button_up() -> void:
	image_filename = ""

func _on_open_image_file_dialog_file_selected(file_path: String) -> void:
	if not file_path:
		return
	
	image_selected(file_path)
	GlobalSettings.last_opened_image_location = file_path.get_base_dir()

func image_selected(file_path: String):
	var extension = file_path.rsplit(".")[-1]
	if (extension not in ["jpg","png","bmp","tga","svg"]):
		return
	
	print(file_path)
	image_filename = file_path

func _on_foldable_background_color_picker_container_folding_changed(is_folded: bool) -> void:
	if is_folded:
		GlobalSettings.save_file()

func _on_background_color_picker_color_changed(color: Color) -> void:
	var container = %image_preview_container
	var new_style=StyleBoxFlat.new()
	new_style.bg_color = color
	container.add_theme_stylebox_override("panel",new_style)
	GlobalSettings.bg_color = color.to_html(false)
