class_name Pistol
extends Firearm

func shoot() -> void:
	const BULLET = preload("res://scenes/ordnance/ammo/bullet.tscn")
	var new_bullet = BULLET.instantiate()
	new_bullet.global_position = %PistolShootingPoint.global_position
	new_bullet.global_rotation = %PistolShootingPoint.global_rotation
	var world = get_tree().current_scene
	world.add_child(new_bullet)
	#%PistolShootingPoint.get_parent().get_parent().add_child(new_bullet)
