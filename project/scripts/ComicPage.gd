class_name ComicPage
extends Resource

var type = ComicPage
var id: String
var raw_text: String

var title: String

func _init(pid: String) -> void:
	id = pid
	var split = pid.split("pg")
	title = "Page " + var_to_str(int(pid.split("pg")[-1]))
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
