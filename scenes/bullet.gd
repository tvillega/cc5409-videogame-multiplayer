extends Area2D


func _physics_process(delta : float) -> void:
	var direction = Vector2.RIGHT.rotated(rotation)
	position += direction * 1000 * delta
	
