@tool
extends PanelContainer

@onready var panel_image_container = %panel_image_container
@onready var panel_scaling_container = %panel_scaling_container

@export var panel_image: Texture2D: 
	set(value): 
		panel_image = value
		if value and panel_image_container:
			panel_image_container.texture =  value
			panel_scaling_container.update_image_size(value.get_size())

func _ready() -> void:
	panel_image_container.texture = panel_image

func set_panel_zoom(value):
	panel_scaling_container._scale = value
