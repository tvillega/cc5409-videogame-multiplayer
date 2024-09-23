class_name npc
extends CharacterBody2D

var speed = 100
var player = null

func _physics_process(delta):
	velocity = Vector2.ZERO
	if player:
		velocity = position.direction_to(player.position) * speed
	move_and_slide()

# Called when the node enters the scene tree for the first time.
#func _ready():
	#pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
	#pass

func _on_DetectRadius_body_entered(body):
	player = body

func _on_DetectRadius_body_exited(body):
	player = null
