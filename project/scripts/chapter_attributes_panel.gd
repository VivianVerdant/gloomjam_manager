extends PanelContainer

var chapter: ComicChapter: set = on_chapter_updated
var language_code: String: set = on_language_code_updated
var title: String: set = on_title_updated

signal panel_updated(chapter, lang)

func on_language_code_updated(value):
	language_code = value
	%language_code_label.text = value

func on_chapter_updated(value):
	chapter = value
	update_panel()

func on_title_updated(value):
	title = value
	update_chapter()

func update_chapter():
	chapter.title[language_code] = title
	
	emit_signal("panel_updated", chapter, language_code)
	
func update_panel():
	if chapter.title.has(language_code):
		%chapter_title_text.text = chapter.title[language_code]

func _on_accept_delete_button_up() -> void:
	chapter.delete_language(language_code)

func _on_chapter_title_text_changed(new_text: String) -> void:
	title = new_text
