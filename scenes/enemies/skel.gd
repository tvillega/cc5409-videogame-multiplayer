class_name Skel
extends Npc

@onready var _animated_sprite : AnimatedSprite2D = $Sprite/AnimatedSprite2D
@onready var hitbox = $Hitbox

func _ready() -> void:
	if multiplayer.is_server():
		detection_area.body_entered.connect(_on_body_entered)
		detection_area.body_exited.connect(_on_body_exited)
		if target:
			hitbox.damage_dealt.connect(_on_damage_dealt)

func _process(_delta):
	if target:
		_animated_sprite.play("chase")
		
	else:
		_animated_sprite.play("idle")

func take_damage(damage: int):
	Debug.log("Skel says auch! -%d" % damage)

func _on_damage_dealt() -> void:
	Debug.log("Skel made damage")
 
