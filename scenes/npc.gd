class_name npc
extends CharacterBody2D

var speed = 100
var player = null
var count = 0

func velocity_y(count):
	return sin((PI * count) / 30) * 20 / 2 * PI
	
func velocity_x(count):
	return cos((PI * count) / 30) * 20 / 2 * PI

func _physics_process(delta):
	
	velocity.y = velocity_y(count)
	velocity.x = velocity_x(count)
	count += 1
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
