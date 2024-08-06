class_name Hitbox extends Area3D


signal hit_recieved(info: HitInfo)
signal health_depleted


@export var health: float


var is_health_depleted: bool


func hit(info: HitInfo):
	if is_health_depleted: return
	
	health -= info.damage
	if health <= 0:
		health = 0
		is_health_depleted = true
	
	hit_recieved.emit(info)
	if is_health_depleted: health_depleted.emit()
