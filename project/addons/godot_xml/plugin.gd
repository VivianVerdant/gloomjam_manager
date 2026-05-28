@tool
extends EditorPlugin

const node := preload("res://addons/godot_xml/xml_node.gd")
const icon := preload("res://addons/godot_xml/icon.svg")

func _enter_tree() -> void:
	add_custom_type("GodotXML", "RefCounted", node, icon)

func _exit_tree() -> void:
	remove_custom_type("GodotXML")
