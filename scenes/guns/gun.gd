class_name Gun
extends Node2D

@export var player_id : int = -1
@onready var gun_synchronizer: InputSynchronizer = $InputSynchronizer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func setup(id: int)-> void:
	player_id = id
	set_multiplayer_authority(id)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.

func _process(delta: float) -> void:
	if is_multiplayer_authority():
		global_rotation = global_position.direction_to(get_global_mouse_position()).angle()

	
	if gun_synchronizer.shooting:
		shoot()
	gun_synchronizer.shooting = false
	
	
func shoot() -> void:
	const BULLET = preload("res://scenes/guns/bullet.tscn")
	var new_bullet = BULLET.instantiate()
	new_bullet.global_position = %ShootingPoint.global_position
	new_bullet.global_rotation = %ShootingPoint.global_rotation
	%ShootingPoint.get_parent().get_parent().add_child(new_bullet)
