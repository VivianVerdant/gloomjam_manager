extends Node

var full_console_node: CanvasItem : set = on_full_console_node_changed
var scroll_container: ScrollContainer
var last_console_node: CanvasItem

func on_full_console_node_changed(value) -> void:
	full_console_node = value
	scroll_container = value.get_parent()
	scroll_container.get_v_scroll_bar().changed.connect(_on_scrollbar_changed)

func print(...args):
	last_console_node.self_modulate = Color.WHITE
	write_text(args)
	
func warn(...args):
	last_console_node.self_modulate = Color.YELLOW
	var arr = ["!"]
	arr.append_array(args)
	write_text(arr)

func write_text(args):
	if args.size() > 0:
		var string: String = ""
		
		for a in args:
			if typeof(a) == TYPE_STRING:
				string += a
			elif typeof(a) == TYPE_DICTIONARY:
				string += "\n%s\n" % var_to_str(a)
			else:
				string += var_to_str(a)
			string += " "
		
		string = string.strip_edges(false)
		var text_line: Node
		if string.begins_with("!"):
			string = string.lstrip("! ")
			text_line = full_console_node.get_child(1).duplicate()
			text_line.show()
		else:
			text_line = full_console_node.get_child(0).duplicate()
		text_line.text = string
		full_console_node.add_child(text_line)
		print(string)
		#last_console_node.title = "Console: " + string
		last_console_node.title = string
		#full_console_node.get_parent().scroll_vertical = full_console_node.size.y + 100
		#full_console_node.get_parent().set_as_ratio.call_deferred(1.)

func _on_scrollbar_changed() -> void:
	scroll_container.scroll_vertical = scroll_container.get_v_scroll_bar().max_value
