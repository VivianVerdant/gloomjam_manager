extends PanelContainer

var chapter: ComicChapter

@onready var raw_text_node = %chapter_raw_text
var raw_text: String: set = on_update_raw_text

var languages: Array = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func on_update_raw_text(value):
	raw_text = value
	raw_text_node.text =  value
