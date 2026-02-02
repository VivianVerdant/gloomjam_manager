extends MarginContainer

@onready var image = $transform_container

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_mask & 8:
		image.visual_scale += Vector2(0.1,0.1)
	if event is InputEventMouseButton and event.button_mask & 16:
		image.visual_scale -= Vector2(0.1,0.1)
	image.visual_scale.x = clamp(image.visual_scale.x, 0.25, 2.0)
	image.visual_scale.y = clamp(image.visual_scale.y, 0.25, 2.0)
	
	if event is InputEventMouseMotion and Input.get_mouse_button_mask() & 1:
		image.visual_position += event.relative
	
	if event is InputEventMouseButton and event.button_mask & 2:
		image.visual_scale = Vector2.ONE
		image.visual_position = Vector2.ZERO
