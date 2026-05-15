extends PanelContainer

var comic: ComicDatabase: set = on_comic_updated

signal panel_updated(comic)

func on_comic_updated(value):
	comic = value
	update_panel()

func update_panel():
	var dropdown = %page_type_selector
	match comic.attributes.page_type:
		"paginated":
			dropdown.select(0)
		"scrolling":
			dropdown.select(0)

func _on_page_type_selector_item_selected(index: int) -> void:
	match index:
		0:
			comic.attributes.page_type = "paginated"
		1:
			comic.attributes.page_type = "scrolling"
	
	panel_updated.emit(comic)
