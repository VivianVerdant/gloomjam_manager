class_name QueuedFileChange
extends Resource

var source_path: String
var destination_path: String
var enabled: = true
var overwriting: = false
var requester: Variant

func _init(source: String, dest: String, req: Variant, en: = true) -> void:
	self.source_path = source
	self.destination_path = dest
	self.enabled = en
	self.requester = req
	if FileAccess.file_exists(GlobalSettings.export_path.path_join(self.destination_path)):
		self.overwriting = true
	
func write_changes(dir: DirAccess) -> Error:
	if self.enabled:
		dir.make_dir_recursive_absolute(destination_path)
		var result = dir.copy(source_path, destination_path)
		if result == Error.OK:
			Console.print("copied:", source_path, " To:", destination_path)
			if self.requester.has_method("make_relative"):
				self.requester.make_relative(source_path, destination_path)
		else:
			Console.warn("!Error copying file: ", error_string(result))
		return result
	return Error.ERR_SKIP
