extends Npc

@onready var _animated_sprite : AnimatedSprite2D = $Sprite/AnimatedSprite2D

func _process(_delta):
	if target:
		_animated_sprite.play("chase")
		
	else:
		_animated_sprite.play("idle")
