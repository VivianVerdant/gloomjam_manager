extends PanelContainer

var page: ComicPage: set = on_page_updated
var language_code: String: set = on_language_code_updated
var title: String: set = on_title_updated
var image_filename: String: set = on_image_filename_updated
var author_comment: String: set = on_author_comment_updated

signal panel_updated(page, lang)

var panel_zoom: float = 50.: set = on_panel_zoome_updated
signal panel_zoom_changed(value)

func _ready():
	for node in %strip_container.get_children():
		panel_zoom_changed.connect(node.set_panel_zoom)
	_on_background_color_picker_color_changed(GlobalSettings.bg_color)

func on_file_dropped(file_path: String):
	if not file_path:
		return
		
	var extension = file_path.rsplit(".")[-1]
	if (extension in ["jpg","png","bmp","tga","svg"]):
		print(file_path)
		image_filename = file_path

func _on_open_page_image_button_button_up() -> void:
	%open_image_file_dialog.show()

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
	
	if value == "":
		%image_drop_container.show()
		%image_preview_container.hide()
		%page_image.texture = null
		%delete_page_image_button.hide()
	else:
		if image_filename.is_relative_path():
			value = GlobalSettings.last_db_path.path_join(image_filename)
		%image_drop_container.hide()
		%image_preview_container.show()
		%delete_page_image_button.show()
		var image = Image.load_from_file(value)
		var texture = ImageTexture.create_from_image(image)
		%page_image.texture = texture
		
	update_page()
	
func on_author_comment_updated(value):
	author_comment = value
	update_page()
	
func update_page():
	page.attributes.title[language_code] = title
	page.attributes.image_filename[language_code] = image_filename
	page.attributes.author_comment[language_code] = author_comment
	
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
		
	var extension = file_path.rsplit(".")[-1]
	if (extension in ["jpg","png","bmp","tga","svg"]):
		print(file_path)
		image_filename = file_path


func _on_zoom_out_button_up() -> void:
	panel_zoom -= 5.
	panel_zoom = clampf(panel_zoom, 20., 200.)

func _on_zoom_in_button_up() -> void:
	panel_zoom += 5.
	panel_zoom = clampf(panel_zoom, 20., 200.)

func on_panel_zoome_updated(value):
	panel_zoom = value
	panel_zoom_changed.emit(value)
	%zoom_percent_label.text = str(value).left(-2) + "%"

func _on_background_color_picker_color_changed(color: Color) -> void:
	var container = %image_preview_container
	var new_style=StyleBoxFlat.new()
	new_style.bg_color = color
	container.add_theme_stylebox_override("panel",new_style)
	GlobalSettings.bg_color = color.to_html(false)


func _on_foldable_background_color_picker_container_folding_changed(is_folded: bool) -> void:
	if is_folded:
		GlobalSettings.save_file()
