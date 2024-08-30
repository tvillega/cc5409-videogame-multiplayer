extends CharacterBody2D

var speed = 400
var gravity = 600
var jump_speed = 500
var acceleration = 1000

var player
@onready var label: Label = $Label
@onready var input_synchronizer: InputSynchronizer = $InputSynchronizer

func _input(event: InputEvent) -> void:
	if is_multiplayer_authority():
		if event.is_action_pressed("test"):
			test.rpc()


func _physics_process(delta: float) -> void:
	#if is_multiplayer_authority():
	
	var directions = input_synchronizer.directions 
	velocity = directions * speed
	look_at(get_global_mouse_position())
	
	if is_on_floor() and input_synchronizer.jump:
		velocity.y = -jump_speed
	input_synchronizer.jump = false
	
	# send_position.rpc(position, velocity)
	move_and_slide()


func setup(player_data: Statics.PlayerData) -> void:
	name = str(player_data.id)
	set_multiplayer_authority(player_data.id)
	#input_synchronizer.set_multiplayer_authority(player_data.id, false)
	label.text = player_data.name
	player = player_data


@rpc("authority", "call_local", "unreliable")
func test():
	Debug.log("test %s" % player.name)


@rpc
func send_position(pos: Vector2, vel: Vector2) -> void:
	position = lerp(position, pos, 0.5)
	velocity = lerp(velocity, vel, 0.5)
