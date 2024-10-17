class_name Player
extends CharacterBody2D

@export var speed = 400
@export var jump_speed = 6000
@export var acceleration = 1000
@export var is_tank = true
@export var dead = false

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
@onready var pistol: Firearm = $Pistol
@onready var shotgun: Firearm = $Shotgun
@onready var stats = $Stats
@onready var animated_sprite_2d = $AnimatedSprite2D

var movement_orient = ""

func _process(_delta):
	if stats.health == 0 and not dead:
		dead = true
		animated_sprite_2d.play("death")
	else: if not dead:
		animated_sprite_2d.play("idle_down")
	
func _input(event: InputEvent) -> void:
	if is_multiplayer_authority():
		if event.is_action_pressed("test"):
			test.rpc()
				

func _physics_process(delta: float) -> void:
	if is_multiplayer_authority():
		if input_synchronizer.pause:
			pauseMenu()
		input_synchronizer.pause = false
	
	if not dead:
		var directions = input_synchronizer.directions
		velocity = directions * speed
		if input_synchronizer.jump:
			velocity += directions * jump_speed
		
		input_synchronizer.jump = false
		if input_synchronizer.swap:
			if is_tank:
				is_tank = false
				remove_child(pistol)
				add_child(shotgun)
			else:
				is_tank = true
				remove_child(shotgun)
				add_child(pistol)
		input_synchronizer.swap = false
		
	move_and_slide()


func setup(player_data: Statics.PlayerData) -> void:
	name = str(player_data.id)
	set_multiplayer_authority(player_data.id)
	pistol.set_multiplayer_authority(player_data.id)
	shotgun.set_multiplayer_authority(player_data.id)
	remove_child(shotgun)
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
	stats.health -= damage
	# Avoid sending text twice
	if multiplayer.is_server():
		Debug.log("Player says auch! -%d" % damage)
		Debug.log("Player health at %d" % stats.health)
