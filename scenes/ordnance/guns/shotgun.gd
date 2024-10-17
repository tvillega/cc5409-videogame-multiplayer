class_name Shotgun
extends Firearm

func shoot() -> void :
	const SHELL = preload("res://scenes/ordnance/ammo/shell.tscn")
	var new_shell_arr = Array()
	var world = get_tree().current_scene
	for i in range(5):
		var new_shell = SHELL.instantiate()
		new_shell.global_position = %ShotgunShootingPoint.global_position
		new_shell.global_rotation_degrees = %ShotgunShootingPoint.global_rotation_degrees - 5 + i * 10/5
		new_shell_arr.append(new_shell)
	for shell in new_shell_arr:
		#%ShotgunShootingPoint.get_parent().get_parent().add_child(shell)
		world.add_child(shell)
