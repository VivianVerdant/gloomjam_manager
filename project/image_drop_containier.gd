extends CenterContainer

@onready var root = $"../../../../.."

func recieve_dropped_file(file_path):
	root.on_file_dropped(file_path)
