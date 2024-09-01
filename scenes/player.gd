extends CharacterBody2D

var speed = 400
var gravity = 600
var jump_speed = 6000
var acceleration = 1000

var player
@onready var label: Label = $Label
@onready var input_synchronizer: InputSynchronizer = $InputSynchronizer
@onready var camera_2d: Camera2D = $Camera2D
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var tank_gun: Area2D = $TankGun
var movement_orient = ""
	
func _input(event: InputEvent) -> void:
	if is_multiplayer_authority():
		if event.is_action_pressed("test"):
			test.rpc()
			

func _physics_process(delta: float) -> void:
	if is_multiplayer_authority():
		pass
		
	var directions = input_synchronizer.directions
	velocity = directions * speed
	if input_synchronizer.jump:
		velocity += directions * jump_speed
	
	input_synchronizer.jump = false
	
	send_position.rpc(position, velocity)
	move_and_slide()


func setup(player_data: Statics.PlayerData) -> void:
	name = str(player_data.id)
	set_multiplayer_authority(player_data.id)
	tank_gun.set_multiplayer_authority(player_data.id)
	#input_synchronizer.set_multiplayer_authority(player_data.id, false)
	label.text = player_data.name
	player = player_data
	camera_2d.enabled = is_multiplayer_authority()


@rpc("authority", "call_remote", "unreliable")
func test():
	Debug.log("player: %s directions: %s" % [player.name, movement_orient])

@rpc("authority")
func send_position(pos: Vector2, vel: Vector2) -> void:
	position = lerp(position, pos, 0.5)
	velocity = lerp(velocity, vel, 0.5)
	
