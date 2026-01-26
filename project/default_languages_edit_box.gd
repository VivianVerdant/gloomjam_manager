extends LineEdit

func _ready() -> void:
	var langs = GlobalSettings.default_languages
	var string: String = ""
	for lang in langs:
		string += lang
		string += ","
	string = string.rstrip(",")
	text = string
	

func _on_editing_toggled(toggled_on: bool) -> void:
	if not toggled_on:
		var arr: Array = []
		text = text.replace(" ", "")
		arr = text.split(",", false)
		GlobalSettings.default_languages = arr
		GlobalSettings.save_file()
