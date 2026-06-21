extends Node

@onready var db_tree: Tree = %tree

var current_language = "en"

var current_database_file: String 	# absolute path to database file
var current_database: ComicDatabase
var current_tree_selection
var current_database_item_selected

@onready var comic_attributes_panel = load("res://scenes/comic_attributes_panel.tscn")
@onready var page_attributes_panel = load("res://scenes/page_attributes_panel.tscn")
@onready var scrolling_page_attributes_panel = load("res://scenes/scrolling_page_attributes_panel.tscn")
@onready var chapter_attributes_panel = load("res://scenes/chapter_attributes_panel.tscn")

@onready var attributes_panel_scroll_container = %attributes_hbox_container

var console_output = ""

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("new"):
		_on_new_db()
	if event.is_action_pressed("open"):
		_on_open_db()
	if event.is_action_pressed("save"):
		_on_save_database_button_pressed()
	if event.is_action_pressed("save_as"):
		%save_database_file_dialog.show()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	%queued_file_changes_panel.hide()
	%app_console_drawer_full.syntax_highlighter.add_color_region("!", "", Color.YELLOW, true)
	#%app_console_drawer_full.syntax_highlighter.add_keyword_color("Warning", Color.RED)
	
	Console.full_console_node = %app_console_drawer_full
	Console.last_console_node = %app_console_container
	GlobalSettings.load_settings()
	db_tree.set_column_title(0, "ID")
	db_tree.set_column_title(1, "Title")
	db_tree.root = self
	%open_database_file_dialog.current_path = GlobalSettings.last_db.get_base_dir()
	%open_database_file_dialog.current_file = GlobalSettings.last_db.get_file()
	get_viewport().files_dropped.connect(on_files_dropped)
	%thumbnail_container.hide()
	
	var args = OS.get_cmdline_args()
	print("CMD args: ", args)
	if args.size() == 1:
		var string: String = args[0]
		if string.get_extension() == "jam":
			GlobalSettings.last_db = string
			_on_open_database_file(string)
	else:
		if GlobalSettings.last_db == "":
			GlobalSettings.last_db = OS.get_executable_path()
			%open_previous.disabled = true
		%new_or_open.show()
	
func on_files_dropped(files):
	Console.print("Dropped file(s):", files)
	var viewport = get_viewport()
	viewport.get_window().grab_focus()
	var input = InputEventMouseMotion.new()
	input.position = viewport.get_mouse_position()
	input.button_mask = 1
	viewport.push_input(input)
	var control = get_viewport().gui_get_hovered_control()
	if control.find_parent("thumbnail_container"):
		Console.print("Dropped file:", files[0])
		on_thumbnail_dropped(files[0])
		_on_tree_cell_selected()
		return
	while control.get_parent():
		if control.has_method("image_selected"):
			control.image_selected(files[0])
			break
		control = control.get_parent()
	
	Console.print("Invalid drop area")

func on_thumbnail_dropped(file_path: String) -> void:
	if not file_path or current_database_item_selected.type != ComicPage:
		Console.print("How did you get here?")
		return
	
	GlobalSettings.last_opened_image_location = file_path.get_base_dir()
	
	var file_location = file_path
	if file_location.is_relative_path():
		file_location = GlobalSettings.export_path.path_join(file_location)
	
	var extension = file_path.get_extension()
	if (extension in GlobalSettings.VALID_IMAGETYPES):
		current_database_item_selected.attributes.thumbnail = file_path
		%thumbnail_unloaded_container.hide()
		%thumbnail_loaded_container.show()
		if not FileAccess.file_exists(file_location):
			Console.warn("!Warning: File does not exist at:", file_location)
			return
		Console.print("Assigning " + file_path + " as thumbnail")
		var image = Image.load_from_file(file_location)
		var texture = ImageTexture.create_from_image(image)
		%thumbnail_display_rect.texture = texture
	else:
		Console.print("Invalid filetype:", file_path)
	
	%raw_data.text = JSON.stringify(current_database_item_selected.to_dict(), "\t", false)
	
func on_thumbnail_deleted() -> void:
	current_database_item_selected.attributes.thumbnail = ""
	%thumbnail_unloaded_container.show()
	%thumbnail_loaded_container.hide()
	Console.print("Deleting thumnail")
	_on_tree_cell_selected()
	
func _on_open_previous_button_up() -> void:
	_on_open_database_file(GlobalSettings.last_db)
	
func _on_open_database_file(path: String) -> void:
	current_database_file = path
	var text = FileAccess.get_file_as_string(path)
	var json = JSON.new()
	var error = json.parse(text)
	if error == OK:
		var data_received = json.data
		if typeof(data_received) == TYPE_DICTIONARY:
			Console.print("Loaded File:", path)
			if not data_received.has("gjdb_type"):
				data_received["gjdb_type"] = "ComicDatabase"
			match data_received.gjdb_type:
				"ComicDatabase":
					current_database = ComicDatabase.new(data_received)
					current_language = current_database.attributes.languages[0]
					create_interactive_database()
			
					GlobalSettings.last_db = path
					if current_database.attributes.export_subdirectory != "":
						GlobalSettings.export_path = current_database_file.get_base_dir().path_join(current_database.attributes.export_subdirectory)
					else:
						GlobalSettings.export_path = current_database_file.get_base_dir()
					for node in [%save_database_button,%save_database_as_button,%commit_database_button]:
						node.disabled = false
				"BlogDatabase":
					pass
		else:
			Console.print("Unexpected data")
	else:
		Console.print("JSON Parse Error: ", json.get_error_message(), " in ", text, " at line ", json.get_error_line())

func create_interactive_database():
	if db_tree.get_root():
		db_tree.get_root().free()
		
	var root: TreeItem = db_tree.create_item();
	root.set_text(0, current_database.attributes.id)
	db_tree.set_selected(root, 0)
	#Console.print("Loaded root:", current_database.attributes.id)
	for chapter in current_database.attributes.chapters:
		#Console.print("Loaded chapter:",chapter.attributes.title[current_language])
		var chapter_obj = root.create_child()
		chapter_obj.set_text(0, chapter.attributes.id)
		chapter_obj.set_text(1, chapter.attributes.title[current_language])
		for page in chapter.attributes.pages:
			var page_node = chapter_obj.create_child()
			page_node.set_text(0, page.attributes.id)
			page_node.set_text(1, page.attributes.title[current_language])
			#Console.print("Loaded page:", page.attributes.title[current_language])
		if chapter != current_database.attributes.chapters[-1]:
			chapter_obj.collapsed = true

func _on_tree_cell_selected() -> void:
	%change_page_type_panel.hide()
	%thumbnail_container.hide()
	%pub_date_container.hide()
	var selected: TreeItem = db_tree.get_selected()
	#if selected == current_tree_selection:
		#return
	current_tree_selection = selected
	
	for node in attributes_panel_scroll_container.get_children():
		node.free()
		
	var id = selected.get_text(0)
	
	var obj = current_database.get_resource_by_id(id)
	current_database_item_selected = obj
	#Console.print("selected:", selected.get_text(0))
	
	if not obj:
		%add_language_text.editable = false
		%add_language_button.disabled = true
		%item_id_text.text = ""
		%item_id_text.editable = false
		%raw_data.text = JSON.stringify(current_database.to_dict(), "\t", false)
		return

	#Console.print(obj)
	
	%raw_data.text = JSON.stringify(obj.to_dict(), "\t", false)
	
	Console.print("Selected item:", obj.attributes.id)
	
	match obj.type:
		ComicDatabase:
			edit_comic(obj)
		ComicChapter:
			edit_chapter(obj)
		ComicPage:
			%change_page_type_panel.show()
			%thumbnail_container.show()
			%pub_date_container.show()
			edit_page(obj)
		_:
			pass
	
func create_new_comic_database(result):
	if result:
		Console.print("Creating new Comic Database")
		current_database = ComicDatabase.new({})
		current_database.dirty = true
		create_interactive_database()
		for node in [%save_database_button,%save_database_as_button,%commit_database_button]:
			node.disabled = false
	else:
		Console.print("Action canceled")
	
func close_current_db(callable: Callable) -> void:
	%confirm_unsaved_changes.confirm_continue(callable)
		
func _on_open_db() -> void:
	if current_database:
		close_current_db(%open_database_file_dialog.show)
	else:
		%open_database_file_dialog.show()
	
func _on_new_db() -> void:
	if current_database:
		close_current_db(%select_new_db_type.show)
		current_database_file = ""
	else:
		%select_new_db_type.show()
	
func _on_new_comicdb() -> void:
	create_new_comic_database(true)

func _on_new_blogdb() -> void:
	pass

func _on_add_chapter_button_up() -> void:
	if not db_tree.get_root():
		Console.print("No database loaded")
		return
	
	var num_chapters = current_database.attributes.chapters.size()
	var chapter_obj = db_tree.create_item()
	var cid = "ch" + var_to_str(num_chapters + 1)
	db_tree.get_root().add_child(chapter_obj)
	var chapter = current_database.add_chapter(ComicChapter.new({
			"id": cid,
			"title": {
				current_database.attributes.languages[0]: ""
			}
		}))
	chapter_obj.set_text(0, chapter.attributes.id)
	chapter_obj.set_text(1, chapter.attributes.title[current_database.attributes.languages[0]])
	var obj = db_tree.get_root().get_child(-1)
	db_tree.set_selected(obj, 0)
	Console.print("Created chapter:", chapter.attributes.id)

func _on_add_page_button_up() -> void:
	if not db_tree.get_root():
		Console.print("No database loaded")
		return
	
	if not current_tree_selection:
		if not db_tree.get_root().get_child(-1):
			Console.print("No chapters to add page to")
			return
		var obj = db_tree.get_root().get_child(-1)
		db_tree.set_selected(obj, 0)
	
	if db_tree.get_root() == current_tree_selection:
		if db_tree.get_root().get_child_count() == 0:
			Console.print("Must have at least 1 chapter to add pages to.")
			return
			
		var obj = db_tree.get_root().get_child(-1)
		db_tree.set_selected(obj, 0)
	
	var chapter_obj: TreeItem
	var rid = current_tree_selection.get_text(0)
	var item = current_database.get_resource_by_id(rid)
	
	match item.type:
		ComicChapter:
			chapter_obj = db_tree.get_selected()
		ComicPage:
			chapter_obj = db_tree.get_selected().get_parent()
		_:
			return
	
	var chapter = current_database.get_chapter_by_id(chapter_obj.get_text(0))
	var num_pages = chapter.attributes.pages.size()
	var pid = chapter.attributes.id + "pg" + var_to_str(num_pages + 1)
	var page = ComicPage.new({
			"id" :pid,
			"page_type" :current_database.attributes.page_type,
			"title": {
				current_database.attributes.languages[0]: ""
			}
		})
	chapter.add_page(page)
	var page_obj = chapter_obj.create_child()
	page_obj.set_text(0, pid)
	page_obj.set_text(1, page.attributes.title[current_database.attributes.languages[0]])
	db_tree.set_selected(page_obj, 0)
	Console.print("Created page:", pid)

func _on_delete_selected_button_up() -> void:
	%confirm_delete_item_dialog.show()
	%accept_confirm_delete_item.grab_focus()
	
func _on_delete_selected_confirmed() -> void:
	if not current_database:
		return
	
	if not db_tree.get_root():
		Console.print("No database loaded")
		return
	
	if not current_tree_selection:
		return
	
	if db_tree.get_root() == current_tree_selection:
		return
	
	var rid = current_tree_selection.get_text(0)
	var item = current_database.get_resource_by_id(rid)
	
	match item.type:
		ComicChapter:
			item.flagged_for_deletion = true
			for page in item.attributes.pages:
				page.flagged_for_deletion = true
		ComicPage:
			item.flagged_for_deletion = true
		_:
			return
			
	for chapter: ComicChapter in current_database.attributes.chapters:
		for page: ComicPage in chapter.attributes.pages:
			if page.flagged_for_deletion:
				chapter.attributes.pages.erase(page)
				
		if chapter.flagged_for_deletion:
			current_database.attributes.chapters.erase(chapter)
	
	db_tree.get_selected().free()
	db_tree.set_selected(db_tree.get_root(), 0)
	_on_tree_cell_selected()

func edit_comic(comic: ComicDatabase):
	%item_id_text.text = comic.attributes.id
	%item_id_text.editable = true
	var comic_attributes = comic_attributes_panel.instantiate()
	attributes_panel_scroll_container.add_child(comic_attributes)
	comic_attributes.comic = comic
	%raw_data.text = JSON.stringify(comic.to_dict(), "\t", false)
	comic_attributes.panel_updated.connect(on_comic_updated)
	
func on_comic_updated(comic: ComicDatabase):
	%raw_data.text = JSON.stringify(comic.to_dict(), "\t", false)
	if comic.attributes.export_subdirectory != "":
		GlobalSettings.export_path = current_database_file.get_base_dir().path_join(current_database.attributes.export_subdirectory)
	else:
		GlobalSettings.export_path = current_database_file.get_base_dir()

func edit_page(page: ComicPage):
	%item_id_text.text = page.attributes.id
	%item_id_text.editable = true
	if page.attributes.thumbnail == "":
		%thumbnail_unloaded_container.show()
		%thumbnail_loaded_container.hide()
	else:
		var thumbnail_path:String = page.attributes.thumbnail
		on_thumbnail_dropped(thumbnail_path)
		%thumbnail_unloaded_container.hide()
		%thumbnail_loaded_container.show()
	
	%pub_date_text.text = page.attributes.pub_date
	
	if page.attributes.page_type == "scrolling":
		%page_type_selector.select(1)
	else:
		%page_type_selector.select(0)
	for language in current_database.attributes.languages:
		var page_attributes
		if page.attributes.page_type == "scrolling":
			page_attributes = scrolling_page_attributes_panel.instantiate()
		else:
			page_attributes = page_attributes_panel.instantiate()
		attributes_panel_scroll_container.add_child(page_attributes)
		page_attributes.language_code = language
		page_attributes.page = page
		page_attributes.panel_updated.connect(on_page_updated)
		
func on_page_updated(page: ComicPage, _lang):
	current_tree_selection.set_text(1, page.attributes.title[current_database.attributes.languages[0]])
	%raw_data.text = JSON.stringify(current_database_item_selected.to_dict(), "\t", false)

func edit_chapter(chapter: ComicChapter):
	%item_id_text.text = chapter.attributes.id
	%item_id_text.editable = true
	for language in current_database.attributes.languages:
		var chapter_attributes = chapter_attributes_panel.instantiate()
		attributes_panel_scroll_container.add_child(chapter_attributes)
		chapter_attributes.language_code = language
		chapter_attributes.chapter = chapter
		chapter_attributes.panel_updated.connect(on_chapter_updated)

func on_chapter_updated(chapter: ComicChapter, _lang):
	current_tree_selection.set_text(1, chapter.attributes.title[current_database.attributes.languages[0]])
	%raw_data.text = JSON.stringify(current_database_item_selected.to_dict(), "\t", false)

func save_database_file(path: String) -> void:
	var dict = current_database.to_dict()
	match current_database.type:
		ComicDatabase:
			dict["gjdb_type"] = "ComicDatabase"
	var db_string = JSON.stringify(dict, "\t", false)
	var file = FileAccess.open(path, FileAccess.WRITE)
	var result = file.store_string(db_string)
	if result:
		Console.print("Saved database:", path)
	else:
		Console.warn("!Failed to save database")
	GlobalSettings.last_db = path
	
func _on_save_database_button_pressed() -> void:
	if not current_database or current_database_file == "":
		return
		
	save_database_file(current_database_file)
	
func _on_save_database_file_dialog_file_selected(path: String) -> void:
	save_database_file(path)

func _on_save_database_button_selected() -> void:
	var dialog = %save_database_file_dialog
	dialog.current_file = GlobalSettings.last_db
	dialog.show()
	
func _on_item_id_text_submitted(new_text: String) -> void:
	new_text = new_text.strip_edges()
	if current_database.get_resource_by_id(new_text):
		Console.print("New ID must be unique!")
		%item_id_text.text = current_database_item_selected.attributes.id
		return
	else:
		Console.print("changed item ID from", current_database_item_selected.attributes.id, "to", new_text)
		%item_id_text.text = new_text
		current_tree_selection.set_text(0, new_text)
		current_database_item_selected.attributes.id = new_text
		%raw_data.text = JSON.stringify(current_database_item_selected.to_dict(), "\t", false)

func _on_add_language_text_changed(new_text: String) -> void:
	if new_text != "" and current_database_item_selected and current_database_item_selected.get("languages"):
		%add_language_button.disabled = false
	else:
		%add_language_button.disabled = true

func _on_add_language_button_button_up() -> void:
	var lang = %add_language_text.text.strip_edges()
	if lang != "" and current_database_item_selected and current_database_item_selected.get("languages"):
		current_database_item_selected.add_language(lang)
		_on_tree_cell_selected()

func _on_app_console_container_folding_changed(is_folded: bool) -> void:
	if is_folded == true:
		%app_console_split.split_offsets = PackedInt32Array()
		%app_console_split.dragger_visibility = 2
		%app_console_split.dragging_enabled = false
	else:
		%app_console_split.dragger_visibility = 0
		%app_console_split.dragging_enabled = true
		%app_console_scroll_container.custom_minimum_size.y = min(150, %app_console_drawer_full.size.y)

func _on_page_type_selector_item_selected(index: int) -> void:
	current_database_item_selected.attributes.page_type = %page_type_selector.get_item_text(index).to_lower()
	_on_tree_cell_selected()

func _on_pub_date_upadted(value: String) -> void:
	current_database_item_selected.attributes.pub_date = value

func _on_app_console_split_dragged(offset: int) -> void:
	%app_console_scroll_container.scroll_vertical = -offset - 23 + %app_console_drawer_full.size.y

func _on_accept_write_changes_button_up() -> void:
	var dir_access = DirAccess.open(GlobalSettings.export_path)
	for change: QueuedFileChange in GlobalSettings.queued_file_changes:
		change.write_changes(dir_access)
	
	save_database_file(GlobalSettings.last_db)
	save_database_file(GlobalSettings.export_path.path_join("db.json"))
	
	%RSS.write_rss(current_database)
	GlobalSettings.queued_file_changes = []
	%proposed_changes_display_tree.clear_list()
	_on_save_database_button_pressed()
	_on_tree_cell_selected()

func _on_cancel_write_changes_button_up() -> void:
	GlobalSettings.queued_file_changes = []
	%proposed_changes_display_tree.clear_list()
	_on_tree_cell_selected()

func _on_load_thumbnail_button_button_up() -> void:
	if GlobalSettings.last_opened_image_location != "":
		%open_image_file_dialog.current_dir = GlobalSettings.last_opened_image_location
	else:
		%open_image_file_dialog.current_dir = GlobalSettings.last_db.get_base_dir()
	%open_image_file_dialog.show()

func _on_commit_database_button_selected() -> void:
	if not current_database or not current_database_file:
		return
		
	_on_save_database_button_pressed()
	GlobalSettings.queued_file_changes = []
	current_database.queue_export(GlobalSettings.export_path)
	%queued_file_changes_panel.show()
	%db_file_export_path_lineedit.text = GlobalSettings.export_path.path_join("db.json")
	%rss_export_path_lineedit.text = GlobalSettings.export_path.path_join("atom.xml")
	
	update_queued_changes_panel()
	
func update_queued_changes_panel():
	var root_folder = current_database_file.get_base_dir().path_join(current_database.attributes.export_subdirectory)
	var new_file = JSON.stringify(current_database.to_dict(true), "\t", false)
	var existing_file = FileAccess.get_file_as_string(root_folder.path_join("db.json"))
	if new_file != existing_file:
		%db_export_new_icon.show()
	else:
		%db_export_new_icon.hide()
	
	var new_rss = %RSS.rss_string(current_database)
	var existing_rss = FileAccess.get_file_as_string(GlobalSettings.export_path.path_join("atom.xml"))
	if new_rss != existing_rss:
		%rss_export_new_icon.show()
	else:
		%rss_export_new_icon.hide()
	
	%proposed_changes_display_tree.clear_list()
	for item in GlobalSettings.queued_file_changes:
			%proposed_changes_display_tree.add_row(item)
