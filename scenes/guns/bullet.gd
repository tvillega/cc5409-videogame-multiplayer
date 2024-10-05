extends Area2D


func _physics_process(delta : float) -> void:
	var direction = Vector2.RIGHT.rotated(rotation)
	position += direction * 1000 * delta
	
@rpc("call_local")
func send_position(pos: Vector2, vel: Vector2) -> void:
	position = lerp(position, pos, 0.5) 

#Colision con murallas
func _on_body_entered(body: Node2D) -> void: 
	queue_free() 

#Colision con enemigos
func _on_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	queue_free() # Replace with function body.
