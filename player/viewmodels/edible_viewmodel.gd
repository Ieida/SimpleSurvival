class_name EdibleViewmodel extends Viewmodel


var stats: Dictionary
var is_being_eaten: bool


func _unhandled_input(event):
	super._unhandled_input(event)
	if event.is_action(&"interact"):
		if not event.is_echo() and event.is_pressed():
			eat()


func eat():
	pass
