extends PanelContainer

var page: ComicPage: set = on_page_updated
var language_code: String: set = on_language_code_updated
var title: String: set = on_title_updated
var image_filename: String: set = on_image_filename_updated
var author_comment: String: set = on_author_comment_updated

signal panel_updated(page, lang)

var panel_zoom: float = 50.: set = on_panel_zoome_updated
signal panel_zoom_changed(value)

@onready var scrolling_page_data_container = load("res://scenes/scrolling_page_data_container.tscn")

func _ready():
	#for node in %strip_container.get_children():
		#panel_zoom_changed.connect(node.set_panel_zoom)
	_on_background_color_picker_color_changed(GlobalSettings.bg_color)

	%image_drop_container.show()
	%image_preview_container.hide()
	%delete_page_image_button.hide()
	#for child in %strip_container.get_children():
		#child.queue_free()

func on_file_dropped(file_path: String):
	if not file_path:
		return
		
	var extension = file_path.get_extension()
	if (extension in GlobalSettings.VALID_IMAGETYPES):
		Console.print("Assigning ", file_path, "as image")
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
	update_page()

func on_image_filename_updated(value):
	image_filename = value
	if value == "":
		%image_drop_container.show()
		%image_preview_container.hide()
		%delete_page_image_button.hide()
		for child in %strip_container.get_children():
			child.queue_free()
	else:
		if image_filename.is_relative_path():
			value = GlobalSettings.export_path.path_join(image_filename)
			
		%image_drop_container.hide()
		%image_preview_container.show()
		%delete_page_image_button.show()
		var extension = value.rsplit(".")[-1]
		var file_name = value.get_file().get_slice(".", 0)
		var splits = file_name.split("_")
		var start_panel_num = splits[-1].to_int()
		
		var figures = splits[-1].length()
		var directory = value.get_base_dir()
		var base_name = file_name.left(-figures)
		
		for child in %strip_container.get_children():
			child.free()
		
		var panel_array = []
		for i in page.attributes.page_length:
			var next_page_path = directory.path_join(base_name) + str(i + start_panel_num).pad_zeros(figures) + "." + extension
			panel_array.push_back(next_page_path)
		
		for img in panel_array:
			var image = Image.load_from_file(img)
			var texture = ImageTexture.create_from_image(image)
			var panel = scrolling_page_data_container.instantiate()
			panel.panel_image = texture
			%strip_container.add_child(panel)
		
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
		
		image_selected(page.attributes.image_filename[language_code])

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
		
func image_selected(file_path: String):
	%image_drop_container.hide()
	%image_preview_container.show()
	var extension = file_path.rsplit(".")[-1]
	if (extension not in GlobalSettings.VALID_IMAGETYPES):
		return
		
	if file_path.is_relative_path():
		file_path = GlobalSettings.export_path.path_join(file_path)
	
	if not FileAccess.file_exists(file_path):
		return
	
	# TODO: make this not break on paths with more than the one period in the file path and name
	var file_name = file_path.get_file().get_slice(".", 0)
	var splits = file_name.split("_")
	
	if not splits[-1].is_valid_int():
		Console.warn("!Warning: filename must end with a number, instead found \"", file_name, "\"")
		return

	var start_panel_num = splits[-1].to_int()
	var figures = splits[-1].length()
	var directory = file_path.get_base_dir()
	var base_name = file_name.left(-figures)
	var panel_array = [file_path]
	var next_page_num = start_panel_num + 1
	var next_page_path = directory.path_join(base_name) + str(next_page_num).pad_zeros(figures) + "." + extension
	
	var dir = DirAccess.open(directory)

	while (dir.file_exists(next_page_path)):
		panel_array.push_back(next_page_path)
		next_page_num += 1
		next_page_path = directory.path_join(base_name) + str(next_page_num).pad_zeros(figures) + "." + extension
	
	#Console.print(panel_array)
	
	if page.attributes.page_length > panel_array.size():
		Console.warn("!Warning: Found fewer image files than expected, ", panel_array.size(), " out of ", page.attributes.page_length as int)
	
	page.attributes.page_length = panel_array.size() as int
	image_filename = file_path
