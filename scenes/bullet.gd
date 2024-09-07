extends Area2D


func _physics_process(delta : float) -> void:
	var direction = Vector2.RIGHT.rotated(rotation)
	position += direction * 1000 * delta
	
@rpc("call_local")
func send_position(pos: Vector2, vel: Vector2) -> void:
	position = lerp(position, pos, 0.5) 
