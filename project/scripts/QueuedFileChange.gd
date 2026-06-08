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
	if FileAccess.file_exists(GlobalSettings.last_db_path.path_join(self.destination_path)):
		self.overwriting = true
	
func write_changes(dir: DirAccess) -> Error:
	if self.enabled:
		var result = dir.copy(source_path, destination_path)
		if self.requester.has_method("make_relative"):
			self.requester.make_relative(source_path, destination_path)
		Console.print("copied:", source_path, " To:", destination_path)
		return result
	return Error.ERR_SKIP
