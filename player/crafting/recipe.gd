class_name Recipe extends RefCounted


var items: PackedStringArray
var rewards: PackedStringArray
var physical_items: Array[Node3D]


func _init(itms: Array[String], rwrds: Array[String]):
	items = itms
	rewards = rwrds


func _get_crafting_name(n: String) -> String:
	return n.rstrip("0123456789")


func _get_names_from_nodes(nodes: Array[Node3D]) -> PackedStringArray:
	var nms = []
	for n in nodes:
		nms.append(_get_crafting_name(n.name))
	return nms


func get_contained_items(itms: Array[Node3D]) -> Array[Node3D]:
	var itm_nms = _get_names_from_nodes(itms)
	var cntnd_itms = [] as Array[Node3D]
	for i in items.size():
		if not itm_nms.has(items[i]): break
		if not items.has(itm_nms[i]): continue
		cntnd_itms.append(itms[i])
	return cntnd_itms


func has_item(item: Node3D):
	var n = _get_crafting_name(item.name)
	return items.has(n)
