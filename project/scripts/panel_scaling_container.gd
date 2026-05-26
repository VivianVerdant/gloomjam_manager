@tool
extends Control

@export var _scale: float = 100.0: set = on_scale_change
var image_size: Vector2
var adjusted_size: Vector2

@onready var panel_image_container = $panel_image_container

func on_scale_change(value: float) -> void:
	if not panel_image_container or not panel_image_container.texture:
		return
	if image_size == Vector2.ZERO:
		image_size = panel_image_container.texture.get_size()
	_scale = value
	var perc = value/100.
	panel_image_container.scale = Vector2(perc, perc)
	adjusted_size = image_size * perc
	custom_minimum_size = adjusted_size
	panel_image_container.position.x = (size.x / 2.) - ( adjusted_size.x / 2.)
	$size.text = str(panel_image_container.position)

func update_image_size(s: Vector2):
	image_size = s
	adjusted_size = image_size * _scale

#func _ready() -> void:
	#image_size = $panel_image_container.texture.get_size()

func _on_resized() -> void:
	on_scale_change(_scale)
