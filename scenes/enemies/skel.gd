class_name Skel
extends Npc

@onready var _animated_sprite : AnimatedSprite2D = $Sprite/AnimatedSprite2D
@onready var hitbox = $Hitbox

func _ready() -> void:
	if multiplayer.is_server():
		detection_area.body_entered.connect(_on_body_entered)
		detection_area.body_exited.connect(_on_body_exited)

func _process(_delta):
	if target:
		_animated_sprite.play("chase")
		
	else:
		_animated_sprite.play("idle")

func take_damage(damage: int):
	Debug.log("Skel says auch! -%d" % damage)

#Colision con enemigos
func _on_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	var hitbox = body as Hitbox
	if hitbox:
		hitbox.damage_dealt.connect(_on_damage_dealt)
	queue_free() # Replace with function body.
	
func _on_damage_dealt() -> void:
	Debug.log("Skel made damage")
