extends Node

@onready var db_tree = %tree

var current_language = "en"

var current_database_file: String 	# absolute path to database file
var current_database: ComicDatabase
var current_tree_selection
var current_database_item_selected

@onready var page_attributes_panel = load("res://page_attributes_panel.tscn")
@onready var chapter_attributes_panel = load("res://chapter_attributes_panel.tscn")

@onready var attributes_panel_scroll_container = %attributes_hbox_container

var console_output = ""

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Console.full_console_node = %app_console_drawer_full
	Console.last_console_node = %app_console_container
	GlobalSettings.load_settings()
	db_tree.set_column_title(0, "ID")
	db_tree.set_column_title(1, "Title")
	db_tree.root = self
	current_language = GlobalSettings.default_languages[0]
	%default_languages_edit_box.text = GlobalSettings.default_languages.reduce(func(str,i):return str + "," + String(i))
	%open_database_file_dialog.current_path = GlobalSettings.last_db_path.path_join(GlobalSettings.last_db_name)
	%open_database_file_dialog.current_file = GlobalSettings.last_db_name
	get_viewport().files_dropped.connect(on_files_dropped)

func on_files_dropped(files):
	var viewport = get_viewport()
	#print(files)
	viewport.get_window().grab_focus()
	var input = InputEventMouseMotion.new()
	input.position = viewport.get_mouse_position()
	input.button_mask = 1
	viewport.push_input(input)
	var control = get_viewport().gui_get_hovered_control()
	if control.has_method("recieve_dropped_file"):
		control.recieve_dropped_file(files[0])
	
func _on_open_database_file(path: String) -> void:
	current_database_file = path
	var text = FileAccess.get_file_as_string(path)
	var json = JSON.new()
	var error = json.parse(text)
	if error == OK:
		var data_received = json.data
		if typeof(data_received) == TYPE_DICTIONARY:
			Console.print("Loaded File:", path)
			current_database = ComicDatabase.new(data_received)
			create_interactive_database(false)
			GlobalSettings.last_db_path = path.get_base_dir()
			GlobalSettings.last_db_name = path.get_file()
			GlobalSettings.save_file()
			for node in [%save_database_button,%save_database_as_button,%commit_database_button]:
				node.disabled = false
		else:
			Console.print("Unexpected data")
	else:
		Console.print("JSON Parse Error: ", json.get_error_message(), " in ", text, " at line ", json.get_error_line())

func create_interactive_database(dirty: bool):
	if db_tree.get_root():
		db_tree.get_root().free()
	
	var root: TreeItem = db_tree.create_item();
	root.set_text(0, current_database.id)
	db_tree.set_selected(root, 0)
	Console.print("Loaded root:", current_database.id)
	for chapter in current_database.chapters:
		Console.print("Loaded chapter:",chapter.title[current_language])
		chapter.dirty = dirty
		var chapter_obj = root.create_child()
		chapter_obj.set_text(0, chapter.id)
		chapter_obj.set_text(1, chapter.title[current_language])
		for page in chapter.pages:
			page.dirty = dirty
			var page_node = chapter_obj.create_child()
			page_node.set_text(0, page.id)
			page_node.set_text(1, page.title[current_language])
			Console.print("Loaded page:", page.title[current_language])
		if chapter != current_database.chapters[-1]:
			chapter_obj.collapsed = true

func _on_tree_cell_selected() -> void:
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
	
	match obj.type:
		ComicChapter:
			edit_chapter(obj)
		ComicPage:
			edit_page(obj)
		_:
			pass
	
func create_new_database(result):
	if result:
		Console.print("Creating new Comic Database")
		current_database = ComicDatabase.new({})
		create_interactive_database(true)
		for node in [%save_database_button,%save_database_as_button,%commit_database_button]:
			node.disabled = false
	else:
		Console.print("Action canceled")

func _on_new_database_button_selected() -> void:
	if not current_database:
		create_new_database(true)
	else:
		Console.print("Opening confirmation dialog")
		%confirm_clear_database_dialog.confirm_continue(create_new_database)

func _on_add_chapter_button_up() -> void:
	if not db_tree.get_root():
		Console.print("No database loaded")
		return
	
	var num_chapters = current_database.chapters.size()
	var chapter_obj = db_tree.create_item()
	var cid = "ch" + var_to_str(num_chapters + 1)
	db_tree.get_root().add_child(chapter_obj)
	var chapter = current_database.add_chapter(ComicChapter.new({"id":cid}))
	chapter.dirty = true
	chapter_obj.set_text(0, chapter.id)
	chapter_obj.set_text(1, chapter.title[current_language])
	var obj = db_tree.get_root().get_child(-1)
	db_tree.set_selected(obj, 0)


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
	var num_pages = chapter.pages.size()
	var pid = chapter.id + "pg" + var_to_str(num_pages + 1)
	var page = ComicPage.new({"id":pid})
	page.dirty = true
	chapter.add_page(page)
	var page_obj = chapter_obj.create_child()
	page_obj.set_text(0, pid)
	page_obj.set_text(1, page.title[current_language])
	db_tree.set_selected(page_obj, 0)

func _on_delete_selected_button_up() -> void:
	%confirm_delete_item_dialog.show()
	
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
			for page in item.pages:
				page.flagged_for_deletion = true
		ComicPage:
			item.flagged_for_deletion = true
		_:
			return

func edit_page(page: ComicPage):
	%item_id_text.text = page.id
	%item_id_text.editable = true
	%add_language_button.disabled = true if %add_language_text.text == "" else false
	%add_language_text.editable = true
	for language in page.languages:
		var page_attributes = page_attributes_panel.instantiate()
		attributes_panel_scroll_container.add_child(page_attributes)
		page_attributes.language_code = language
		page_attributes.page = page
		page_attributes.panel_updated.connect(on_page_updated)
		
func on_page_updated(page: ComicPage, _lang):
	current_tree_selection.set_text(1, page.title[page.languages[0]])
	%raw_data.text = JSON.stringify(current_database_item_selected.to_dict(), "\t", false)

func edit_chapter(chapter: ComicChapter):
	%item_id_text.text = chapter.id
	%item_id_text.editable = true
	%add_language_text.editable = true
	%add_language_button.disabled = true if %add_language_text.text == "" else false
	for language in chapter.languages:
		var chapter_attributes = chapter_attributes_panel.instantiate()
		attributes_panel_scroll_container.add_child(chapter_attributes)
		chapter_attributes.language_code = language
		chapter_attributes.chapter = chapter
		chapter_attributes.panel_updated.connect(on_chapter_updated)

func on_chapter_updated(chapter: ComicChapter, _lang):
	current_tree_selection.set_text(1, chapter.title[chapter.languages[0]])
	%raw_data.text = JSON.stringify(current_database_item_selected.to_dict(), "\t", false)

func save_database_file(path: String) -> void:
	Console.print(path)
	# current_database.write_to_filesystem(current_database_file)
	var db_string = JSON.stringify(current_database.to_dict(), "\t", false)
	var file = FileAccess.open(path, FileAccess.WRITE)
	file.store_string(db_string)
	
func _on_save_database_button_pressed() -> void:
	if not current_database_file:
		return
		
	save_database_file(current_database_file)
	
func _on_save_database_file_dialog_file_selected(path: String) -> void:
	save_database_file(path)

func _on_save_database_button_selected() -> void:
	var dialog = %save_database_file_dialog
	dialog.current_file = GlobalSettings.last_db_path.path_join(GlobalSettings.last_db_name)
	dialog.show()
	
func _on_item_id_text_submitted(new_text: String) -> void:
	new_text = new_text.strip_edges()
	if current_database.get_resource_by_id(new_text):
		Console.print("New ID must be unique!")
		%item_id_text.text = current_database_item_selected.id
		return
	else:
		Console.print("changed item ID from", current_database_item_selected.id, "to", new_text)
		%item_id_text.text = new_text
		current_database_item_selected.dirty = true
		current_tree_selection.set_text(0, new_text)
		current_database_item_selected.id = new_text

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


func _on_commit_database_button_selected() -> void:
	if not current_database or not current_database_file:
		return
		
	current_database.write_to_filesystem(current_database_file)
	#ComicFilesystem.write_to_filesystem(current_database, GlobalSettings.last_db_path)
