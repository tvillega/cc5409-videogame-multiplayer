class_name Firearm
extends Node2D

@export var player_id : int = -1
@onready var firearm_synchronizer: InputSynchronizer = $InputSynchronizer

func setup(id: int)-> void:
	player_id = id
	set_multiplayer_authority(id)

func _process(delta: float) -> void:
	if is_multiplayer_authority():
		global_rotation = global_position.direction_to(get_global_mouse_position()).angle()
	
	if firearm_synchronizer.shooting:
		shoot()
	firearm_synchronizer.shooting = false
	
func shoot() -> void:
	pass
	# TEMPLATE
	#const BULLET = preload("res://scenes/ordnance/projectile.tscn")
	#var new_bullet = BULLET.instantiate()
	#new_bullet.global_position = %ShootingPoint.global_position
	#new_bullet.global_rotation = %ShootingPoint.global_rotation
	#%ShootingPoint.get_parent().get_parent().add_child(new_bullet)
