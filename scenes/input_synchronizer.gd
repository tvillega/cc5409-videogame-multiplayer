class_name  InputSynchronizer
extends MultiplayerSynchronizer


@export var directions := Vector2()
@export var jump := false


func _physics_process(delta: float) -> void:
	if is_multiplayer_authority():
		directions = Input.get_vector("left", "right", "up", "down" )
		if Input.is_action_just_pressed("jump"):
			jump_broadcast.rpc()


@rpc("call_local")
func jump_broadcast() -> void:
	jump = true
