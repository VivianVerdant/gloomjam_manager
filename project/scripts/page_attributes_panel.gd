extends PanelContainer

var page: ComicPage

@onready var raw_text_node = %raw_text
var raw_text: String: set = on_update_raw_text

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func on_update_raw_text(value):
	raw_text = value
	raw_text_node.text =  value
