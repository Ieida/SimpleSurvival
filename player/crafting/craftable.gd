class_name Craftable extends Area3D


signal destroyed


var recipe: Recipe


func _ready():
	global_position = _get_median_point()


func _physics_process(_delta):
	var p = _get_median_point()
	if _are_items_too_far():
		queue_free()
		destroyed.emit()
		print("items too far, freeing craftable")
		print("items: %s" % recipe.items)
	else:
		global_position = p


func _are_items_too_far() -> bool:
	for i in recipe.physical_items:
		if i is RigidBody3D:
			if i.freeze: return true
		for j in recipe.physical_items:
			if i.global_position.distance_to(j.global_position) > 1.0: return true
	return false


func _decapitalize(n: String):
	n = n.rstrip("0123456789")
	var nn = ""
	for i in n.length():
		if i == 0:
			nn += n[i].to_lower()
			continue
		var c = n[i]
		if c == c.to_upper():
			nn += "_"
			nn += c.to_lower()
		else:
			nn += c
	return nn


func _get_median_point() -> Vector3:
	var p = Vector3.ZERO
	for i in recipe.physical_items:
		p += i.global_position
	p /= recipe.physical_items.size()
	return p


func _spawn_rewards():
	for r in recipe.rewards:
		var n = _decapitalize(r)
		var p = "res://items/%s/%s.tscn" % [n, n]
		var rs = load(p) as PackedScene
		var rwrd_nd = rs.instantiate() as RigidBody3D
		get_tree().current_scene.add_child(rwrd_nd, true)
		rwrd_nd.global_transform = global_transform
		rwrd_nd.translate(Vector3.UP * 0.5)


func craft():
	# NOTE:
	# Might need to disable the items first
	# to prevent bugs
	_spawn_rewards()
	for i in recipe.physical_items:
		i.queue_free()
	queue_free()
