@tool
extends Label

func _ready() -> void:
	text = ProjectSettings.get_setting("application/config/version")
	ProjectSettings.connect("settings_changed", settings_updated)

func settings_updated():
	text = ProjectSettings.get_setting("application/config/version")
