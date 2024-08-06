class_name Viewmodel extends Node3D


signal destroyed


var item: RigidBody3D
@onready var animation_player = $"AnimationPlayer" as AnimationPlayer


func _ready():
	var plchldr = find_child("Placeholder")
	if plchldr: plchldr.queue_free()
	item = get_node("Item/%s" % name) as RigidBody3D


func _unhandled_input(event):
	if event.is_action(&"main_action"):
		main_action()
	elif event.is_action(&"throw"):
		throw()


func main_action():
	pass


func throw():
	item.process_mode = Node.PROCESS_MODE_INHERIT
	item.freeze = false
	var t = item.global_transform
	item.get_parent().remove_child(item)
	get_tree().current_scene.add_child(item, true)
	item.global_transform = t
	item.apply_central_impulse(-global_basis.z * 2.0)
	queue_free()
	destroyed.emit()
