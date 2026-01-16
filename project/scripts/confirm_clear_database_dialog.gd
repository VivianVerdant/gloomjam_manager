extends PopupPanel

var callback: Callable

func _on_accept_button_up() -> void:
	self.hide()
	callback.call(true)

func _on_cancel_button_up() -> void:
	self.hide()
	callback.call(false)

func confirm_continue(callable: Callable) -> void:
	callback = callable
	self.show()
