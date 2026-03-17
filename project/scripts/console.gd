extends Node

var full_console_node: Node
var last_console_node: Node

func print(...args):
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
		last_console_node.title = "Console: " + string
