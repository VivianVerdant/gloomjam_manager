extends Node

@onready var db_tree = %tree

var current_language = "en"

var current_database_file
var current_database: ComicDatabase: set = on_database_updated
var current_tree_selection

@onready var page_attributes_panel = load("res://page_attributes_panel.tscn")
@onready var chapter_attributes_panel = load("res://chapter_attributes_panel.tscn")

var console_output = ""

func _print(...args):
	if args.size() > 0:
		var string: String = "\n"
		
		for a in args:
			if typeof(a) == TYPE_STRING:
				string += a
			else:
				string += var_to_str(a)
			string += " "
		
		string = string.strip_edges(false)
		var console = %app_console_drawer_full
		console.text += string
		console.scroll_vertical = console.get_line_count() + 100
		print(string)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	db_tree.set_column_title(0, "ID")
	db_tree.set_column_title(1, "Title")
	db_tree.root = self

func _on_open_database_file(path: String) -> void:
	current_database_file = path
	var text = FileAccess.get_file_as_string(path)
	var json = JSON.new()
	var error = json.parse(text)
	if error == OK:
		var data_received = json.data
		if typeof(data_received) == TYPE_DICTIONARY:
			_print("Loaded File:", path)
			current_database = data_received
		else:
			_print("Unexpected data")
	else:
		_print("JSON Parse Error: ", json.get_error_message(), " in ", text, " at line ", json.get_error_line())

func on_database_updated(new_value: ComicDatabase):
	if db_tree.get_root():
		db_tree.get_root().free()
	
	current_database = new_value
	var root: TreeItem = db_tree.create_item();
	root.set_text(0, "Comic")
	_print("Loaded root: Comic")
	for chapter in current_database.chapters:
		_print("Loaded chapter:",chapter.title[current_language])
		var chapter_obj = root.create_child()
		chapter_obj.set_text(0, chapter.id)
		chapter_obj.set_text(1, chapter.title[current_language])
		for page in chapter.pages:
			var page_node = chapter_obj.create_child()
			page_node.set_text(0, page.id)
			page_node.set_text(1, page.locales[0].title)
			_print("Loaded page:", page.locales[0].title)
		if chapter != current_database.chapters[-1]:
			chapter_obj.collapsed = true

func _on_tree_cell_selected() -> void:
	var selected: TreeItem = db_tree.get_selected()
	if selected == current_tree_selection:
		return
	current_tree_selection = selected
	
	for node in %attributes_panel_container.get_children():
		node.free()
		
	var id = selected.get_text(0)
	
	var obj = current_database.get_resource_by_id(id)
	_print("selected:", selected.get_text(0))
	
	if not obj:
		return

	_print(obj)
	
	match obj.type:
		ComicChapter:
			edit_chapter(obj)
		ComicPage:
			edit_page(obj)
		_:
			pass
	

func create_new_database(result):
	if result:
		_print("Creating new Comic Database")
		current_database = ComicDatabase.new()
	else:
		_print("Action canceled")


func _on_new_database_button_selected() -> void:
	if not current_database:
		create_new_database(true)
	else:
		_print("Opening confirmation dialog")
		%confirm_clear_database_dialog.confirm_continue(create_new_database)

func _on_add_chapter_button_up() -> void:
	if not db_tree.get_root():
		_print("No database loaded")
		return
	
	var num_chapters = current_database.chapters.size()
	var chapter_obj = db_tree.create_item()
	var cid = "ch" + var_to_str(num_chapters + 1)
	db_tree.get_root().add_child(chapter_obj)
	var chapter = current_database.add_chapter(ComicChapter.new(cid))
	chapter_obj.set_text(0, chapter.id)
	chapter_obj.set_text(1, chapter.title)
	var obj = db_tree.get_root().get_child(-1)
	db_tree.set_selected(obj, 0)


func _on_add_page_button_up() -> void:
	if not db_tree.get_root():
		_print("No database loaded")
		return
	
	if not current_tree_selection:
		if not db_tree.get_root().get_child(-1):
			_print("No chapters to add page to")
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
	var page = ComicPage.new(pid)
	chapter.add_page(page)
	var page_obj = chapter_obj.create_child()
	page_obj.set_text(0, pid)
	page_obj.set_text(1, page.title)

func _on_delete_selected_button_up() -> void:
	if not current_database:
		return

func edit_page(page: ComicPage):
	var page_attributes = page_attributes_panel.instantiate()
	%attributes_panel_container.add_child(page_attributes)
	page_attributes.raw_text = var_to_str(page)

func edit_chapter(chapter: ComicChapter):
	var chapter_attributes = chapter_attributes_panel.instantiate()
	%attributes_panel_container.add_child(chapter_attributes)
	chapter_attributes.raw_text = var_to_str(chapter)



func _on_save_database_file_dialog_file_selected(path: String) -> void:
	_print(path)


func _on_save_database_button_selected() -> void:
	var dialog = %save_database_file_dialog
	dialog.current_file = "db.json"
	dialog.show()
	
