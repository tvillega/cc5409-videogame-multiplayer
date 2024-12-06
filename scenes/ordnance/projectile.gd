class_name Projectile
extends Area2D

@onready var hitbox = $Hitbox

func _physics_process(delta : float) -> void:
	var direction = Vector2.RIGHT.rotated(rotation)
	position += direction * 1000 * delta
	
@rpc("call_local")
func send_position(pos: Vector2, _vel: Vector2) -> void:
	position = lerp(position, pos, 0.5) 

#Colision con murallas
func _on_body_entered(_body: Node2D) -> void: 
	queue_free() 

#Colision con enemigos
func _on_body_shape_entered(_body_rid: RID, body: Node2D, _body_shape_index: int, _local_shape_index: int) -> void:
	var hitbox = body as Hitbox
	if hitbox:
		hitbox.damage_dealt.connect(_on_damage_dealt)
	queue_free() # Replace with function body.

func _on_damage_dealt() -> void:
	Debug.log("Projectile made damage")
