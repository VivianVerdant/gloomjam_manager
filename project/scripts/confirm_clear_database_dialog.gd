extends PopupPanel

var callback: Callable
@onready var root = $"../../../../.."

func _on_accept_button_up() -> void:
	self.hide()
	root._on_save_database_button_pressed()
	callback.call()

func _on_cancel_button_up() -> void:
	self.hide()
	callback.call()

func confirm_continue(callable: Callable) -> void:
	callback = callable
	self.show()
