class_name TankGun
extends Area2D

@export var player_id : int = -1
@onready var gun_synchronizer: InputSynchronizer = $InputSynchronizer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func setup(id: int)-> void:
	player_id = id
	set_multiplayer_authority(id)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	look_at(get_global_mouse_position())
	
	if gun_synchronizer.shooting:
		shoot()
	gun_synchronizer.shooting= false
	
func shoot():
	const BULLET = preload("res://scenes/bullet.tscn")
	var new_bullet = BULLET.instantiate()
	new_bullet.global_position = %ShootingPoint.global_position
	new_bullet.global_rotation = %ShootingPoint.global_rotation
	%ShootingPoint.add_child(new_bullet)
