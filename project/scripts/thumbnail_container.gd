extends TextureRect

func _make_custom_tooltip(_for_text):
	var panel = PanelContainer.new()
	var image = self.duplicate()
	image.expand_mode = TextureRect.EXPAND_KEEP_SIZE
	panel.add_child(image)
	return panel
