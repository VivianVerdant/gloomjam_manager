extends Node

var full_console_node: CanvasItem
var last_console_node: CanvasItem

func print(...args):
	last_console_node.self_modulate = Color.WHITE
	write_text(args)
	
func warn(...args):
	last_console_node.self_modulate = Color.YELLOW
	write_text(args)

func write_text(args):
	if args.size() > 0:
		var string: String = "\n"
		
		for a in args:
			if typeof(a) == TYPE_STRING:
				string += a
			else:
				string += var_to_str(a)
			string += " "
		
		string = string.strip_edges(false)
		full_console_node.text += string
		print(string)
		#last_console_node.title = "Console: " + string
		last_console_node.title = string
		full_console_node.get_parent().scroll_vertical = full_console_node.size.y + 100
		full_console_node.get_parent().call_deferred("scroll_vertical",[999999999999999])
