class_name Player
extends CharacterBody2D

@export var speed = 400
@export var jump_speed = 6000
@export var acceleration = 1000
@export var is_tank = true

var player
var id
@onready var label: Label = $Label
@onready var pause_menu: Control = $Camera2D/PauseMenu
var paused = false
@onready var input_synchronizer: InputSynchronizer = $InputSynchronizer
@onready var multiplayer_synchronizer: MultiplayerSynchronizer = $MultiplayerSynchronizer

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var playback : AnimationNodeStateMachinePlayback = $AnimationTree["parameters/playback"]

@onready var camera_2d: Camera2D = $Camera2D
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var tank_gun: TankGun = $TankGun
@onready var shot_gun: ShotGun = $ShotGun

var movement_orient = ""

	
func _input(event: InputEvent) -> void:
	if is_multiplayer_authority():
		if event.is_action_pressed("test"):
			test.rpc()
				

func _physics_process(delta: float) -> void:
	if is_multiplayer_authority():
		if input_synchronizer.pause:
			pauseMenu()
		input_synchronizer.pause = false
		
	var directions = input_synchronizer.directions
	velocity = directions * speed
	if input_synchronizer.jump:
		velocity += directions * jump_speed
	
	input_synchronizer.jump = false
	if input_synchronizer.swap:
		if is_tank:
			is_tank = false
			remove_child(tank_gun)
			add_child(shot_gun)
		else: 
			is_tank = true
			remove_child(shot_gun)
			add_child(tank_gun)
	input_synchronizer.swap = false
	
	move_and_slide()


func setup(player_data: Statics.PlayerData) -> void:
	name = str(player_data.id)
	set_multiplayer_authority(player_data.id)
	tank_gun.set_multiplayer_authority(player_data.id)
	shot_gun.set_multiplayer_authority(player_data.id)
	remove_child(shot_gun)
	input_synchronizer.set_multiplayer_authority(player_data.id)
	multiplayer_synchronizer.set_multiplayer_authority(player_data.id)

	label.text = player_data.name
	id = player_data.id
	player = player_data
	camera_2d.enabled = is_multiplayer_authority()


@rpc("authority", "call_remote", "unreliable")
func test():
	Debug.log("player: %s directions: %s" % [player.name, movement_orient])

@rpc("authority", "call_local")
func send_position(pos: Vector2, vel: Vector2) -> void:
	position = lerp(position, pos, 0.5)
	velocity = lerp(velocity, vel, 0.5)

func pauseMenu():
	if paused:
		pause_menu.hide()
	else:
		pause_menu.show()
		
	
	paused = !paused
	
func take_damage(damage: int) -> void:
	#notify_take_damage.rpc_id(get_multiplayer_authority(), damage)
	Debug.log("Player says auch! -%d" % damage)

@rpc("any_peer", "call_local", "reliable")
func notify_take_damage(damage:int) -> void:
	Debug.log("damaged received: %d" % damage)
