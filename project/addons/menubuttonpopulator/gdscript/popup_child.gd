@icon("res://addons/menubuttonpopulator/icons/format-list-text.svg")
extends Node

class_name PopupChildGD

@export var enabled : bool = true

@export var is_separator : bool

@export var label_override : String

signal on_popup_item_selected

func select():
	if enabled:
		on_popup_item_selected.emit()
