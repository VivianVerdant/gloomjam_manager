extends Tree

func _ready() -> void:
	create_item()
	#add_row(true, true, "foo", "bar")
	set_column_title(0, "Enabled")
	set_column_expand(0, true)
	set_column_expand_ratio(0, 0)
	
	#set_column_title(1, "Overwriting")
	set_column_expand(1, true)
	set_column_expand_ratio(1, 0)
	
	set_column_title(2, "Source")
	set_column_title(3, "Destination")

func clear_list() -> void:
	clear()
	create_item()

func add_row(queue_item: QueuedFileChange) -> void:
	var enabled: bool = queue_item.enabled
	var overwrite: bool = queue_item.overwriting
	var source: String = queue_item.source_path
	var dest: String = queue_item.destination_path
	
	var row = create_item()
	row.set_cell_mode(0, TreeItem.TreeCellMode.CELL_MODE_CHECK)
	row.set_selectable(0, false)
	row.set_editable(0, true)
	row.set_checked(0, enabled)
	
	row.set_selectable(1, false)
	if overwrite:
		var image = Image.load_from_file("res://icons/file-exclamation-svgrepo-com.svg")
		var texture = ImageTexture.create_from_image(image)
		row.set_cell_mode(1, TreeItem.TreeCellMode.CELL_MODE_ICON)
		row.set_icon(1, texture)
		row.set_tooltip_text(1, "The destination file exists, will be overwritten with the new source file.")
	
	row.set_selectable(2, false)
	row.set_cell_mode(2, TreeItem.TreeCellMode.CELL_MODE_STRING)
	row.set_text(2, source)
	#row.set_text_alignment(2, HorizontalAlignment.HORIZONTAL_ALIGNMENT_RIGHT)
	row.set_text_overrun_behavior(2, TextServer.OVERRUN_NO_TRIMMING)
	
	row.set_selectable(3, false)
	row.set_cell_mode(3, TreeItem.TreeCellMode.CELL_MODE_STRING)
	row.set_text(3, dest)
	#row.set_text_alignment(3, HorizontalAlignment.HORIZONTAL_ALIGNMENT_RIGHT)
	row.set_text_overrun_behavior(3, TextServer.OVERRUN_NO_TRIMMING)

func _on_item_edited() -> void:
	var item = get_edited()
	var index = item.get_index()
	var checked = item.is_checked(0)
	var change: QueuedFileChange = GlobalSettings.queued_file_changes[index]
	change.enabled = checked
	Console.print("Enabled :" if change.enabled else "Disabled :", change.source_path, "->", change.destination_path)
