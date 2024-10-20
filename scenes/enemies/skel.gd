class_name Skel
extends Npc

@onready var hitbox = $Hitbox

#Colision con enemigos
func _on_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	var hitbox = body as Hitbox
	if hitbox:
		hitbox.damage_dealt.connect(_on_damage_dealt)
	queue_free() # Replace with function body.
	
func _on_damage_dealt() -> void:
	Debug.log("NPC made damage")
