class_name ShotGun
extends Gun

func shoot() -> void :
	const PELETS = preload("res://scenes/guns/pelet.tscn")
	var new_pelet_arr = Array()
	for i in range(5):
		var new_pellet = PELETS.instantiate()
		new_pellet.global_position = %ShootingPoint.global_position
		new_pellet.global_rotation_degrees = %ShootingPoint.global_rotation_degrees - 5 + i * 10/5
		new_pelet_arr.append(new_pellet)
	for pelet in new_pelet_arr:
		%ShootingPoint.get_parent().get_parent().add_child(pelet)
		
	
