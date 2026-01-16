extends MenuButton

@onready var root = get_owner()

func _ready() -> void:
	get_popup().id_pressed.connect(popup_item_selected)
	
func popup_item_selected(id):
	var label = get_popup().get_item_text(id)
	root.call("on_app_menu_button_pressed", label)
	
