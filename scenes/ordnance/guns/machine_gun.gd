extends Firearm


@export var fire_sound: AudioStream

func _ready():
	global_position += Vector2(1,1)

func shoot() -> void:
	const BULLET = preload("res://scenes/ordnance/ammo/bullet.tscn")
	var new_bullet = BULLET.instantiate()
	new_bullet.global_position = %MGShootingPoint.global_position
	new_bullet.global_rotation = %MGShootingPoint.global_rotation
	var world = get_tree().current_scene
	world.add_child(new_bullet)
	AudioManager.play_stream(fire_sound, -15)
