extends PanelContainer

var comic: ComicDatabase: set = on_comic_updated

signal panel_updated(comic)

func on_comic_updated(value):
	comic = value
	update_panel()

func update_panel():
	var dropdown = %page_type_selector
	match comic.page_type:
		ComicDatabase.page_types.PAGINATED:
			dropdown.select(0)
		ComicDatabase.page_types.SCROLLING:
			dropdown.select(0)

func _on_page_type_selector_item_selected(index: int) -> void:
	match index:
		0:
			comic.page_type = ComicDatabase.page_types.PAGINATED
		1:
			comic.page_type = ComicDatabase.page_types.SCROLLING
	
	panel_updated.emit(comic)
