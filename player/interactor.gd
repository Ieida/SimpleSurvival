extends RayCast3D


@export var camera: Camera3D
@export var reach_range: float = 1.1


var area: Area3D
var focused_interactable: Node
var is_interacting: bool
var interaction_timer: Timer
var handlers: Array[InteractionHandler]
var handler: InteractionHandler


@onready var interaction_hint: Label = $"../../UI/InteractionHint" as Label
@onready var progress_bar: TextureProgressBar = $"../../UI/InteractionCircle" as TextureProgressBar


func _ready():
	enabled = false
	progress_bar.hide()
	
	# Create area
	area = Area3D.new()
	area.monitorable = false
	area.collision_layer = 0
	area.collision_mask = 2
	var shp = CollisionShape3D.new()
	var sph = SphereShape3D.new()
	sph.radius = reach_range
	shp.shape = sph
	area.add_child(shp)
	add_child(area, false, Node.INTERNAL_MODE_FRONT)
	
	# Create interaction timer
	interaction_timer = Timer.new()
	interaction_timer.one_shot = true
	interaction_timer.timeout.connect(_on_interaction_timer_timeout)
	add_child(interaction_timer, false, Node.INTERNAL_MODE_BACK)


func _unhandled_input(event):
	if event.is_action("interact"):
		if event.is_pressed() and not event.is_echo():
			interact()


func _physics_process(_delta):
	_look_for_interaction()


func _process(_delta):
	if progress_bar.is_visible_in_tree():
		progress_bar.value = (1 - (interaction_timer.time_left / interaction_timer.wait_time)) * 100.0


func _begin_interaction():
	interaction_timer.start(focused_interactable.interaction_duration)
	focused_interactable.begin_interaction()


func _filter_not_visible(a: Node3D) -> bool:
	if not camera.is_position_in_frustum(a.global_position): return false
	target_position = to_local(a.global_position)
	force_raycast_update()
	return not is_colliding()


func _find_interactable(from: Array):
	from.sort_custom(_sort_ascending)
	var intr = null
	var hndl = null
	for i in from:
		var h = get_handler(i)
		if h:
			intr = i
			hndl = h
			break
	
	if intr != focused_interactable:
		interaction_timer.stop()
		progress_bar.hide()
		if focused_interactable:
			_on_interactable_focus_lost()
		focused_interactable = intr
		handler = hndl
		if handler:
			handler.focus_gained.call(intr)
			interaction_hint.text = handler.interaction_hint


func _get_visible_interactable(intrs: Array[Node3D]) -> Node3D:
	for i in intrs:
		if not camera.is_position_in_frustum(i.global_position): continue
		target_position = to_local(i.global_position)
		force_raycast_update()
		if not is_colliding(): return i
	return null


func _look_for_interaction():
	if focused_interactable and not is_instance_valid(focused_interactable):
		_on_interactable_freed()
	
	var intrs: Array = []
	intrs.append_array(area.get_overlapping_areas())
	intrs.append_array(area.get_overlapping_bodies())
	intrs = intrs.filter(_filter_not_visible)
	_find_interactable(intrs)


func _on_interactable_focus_lost():
	if is_interacting:
		cancel_interaction()
	focused_interactable = null
	interaction_hint.text = ""
	handler.focus_lost.call()


func _on_interactable_freed():
	if is_interacting:
		cancel_interaction()
	focused_interactable = null
	interaction_hint.text = ""
	handler.freed.call()


func _on_interactable_gained():
	interaction_hint.text = handler.interaction_hint


func _on_interaction_timer_timeout():
	if not focused_interactable: return
	handler.handle.call(focused_interactable)
	progress_bar.hide()


func _sort_ascending(a, b) -> bool:
	var fwd = -global_basis.z
	var dira = global_position.direction_to(a.global_position)
	var anga = fwd.angle_to(dira)
	var dirb = global_position.direction_to(b.global_position)
	var angb = fwd.angle_to(dirb)
	return angb > anga


func add_handler(hndlr: InteractionHandler):
	handlers.append(hndlr)


func begin_interaction():
	interaction_timer.start()
	progress_bar.show()


func cancel_interaction():
	interaction_timer.stop()


func get_handler(intrctbl) -> InteractionHandler:
	for h in handlers:
		if h.can_handle.call(intrctbl):
			return h
	return null


func interact():
	if not focused_interactable: return
	if handler.duration > 0:
		interaction_timer.start(handler.duration)
		progress_bar.show()
	else:
		handler.handle.call(focused_interactable)


func remove_handler(hndlr: InteractionHandler):
	handlers.erase(hndlr)
