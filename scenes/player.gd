class_name Player
extends CharacterBody2D

@export var speed = 400
@export var jump_speed = 6000
@export var acceleration = 1000
@export var is_tank = true
@export var dead = false
@export var equipment : Array[Node2D]

var player
var id
var _swap_requester: int
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
@onready var pistol: Pistol = $Pistol
@onready var shotgun: Shotgun = $Shotgun

@onready var stats = $Stats
#@onready var hud: HUD = $HUD
@onready var health_bar = $HealthBar
@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var swap_timer: Timer = $SwapTimer
@onready var swap_progress_bar: ProgressBar = $SwapProgressBar

var movement_orient = ""

func _ready() ->  void:	
	stats.health_changed.connect(_on_health_changed)
	#hud.health = stats.health
	#hud.visible = is_multiplayer_authority()
	health_bar.value = stats.health
	#swap_progress_bar.visible = is_multiplayer_authority()
	#health_bar.visible = not is_multiplayer_authority()
	swap_progress_bar.visible = is_multiplayer_authority()
	swap_timer.timeout.connect(_on_swap_timer_timeout)
	swap_progress_bar.hide()
	
func _process(_delta):
	if stats.health <= 0 and not dead:
		playerDeath.rpc()
	else: if not dead:
		animated_sprite_2d.play("idle_down")
	
	if not swap_timer.is_stopped():
		swap_progress_bar.value = swap_timer.time_left
	
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
		
		if is_multiplayer_authority():
			if Input.is_action_just_pressed("swap"):
				request_swap()
	move_and_slide()


func setup(player_data: Statics.PlayerData) -> void:
	name = str(player_data.id)
	set_multiplayer_authority(player_data.id)
	pistol.set_multiplayer_authority(player_data.id)
	shotgun.set_multiplayer_authority(player_data.id)
	if player_data.role == Statics.Role.MEDIC: 
		
		player_data.equipment.append(pistol)	
		remove_child(shotgun)
	else: 
	
		player_data.equipment.append(shotgun)
		remove_child(pistol)
		
	
	input_synchronizer.set_multiplayer_authority(player_data.id)
	multiplayer_synchronizer.set_multiplayer_authority(player_data.id)

	label.text = player_data.name
	id = player_data.id
	player = player_data
	camera_2d.enabled = is_multiplayer_authority()
	update_equipment()	


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

@rpc("any_peer", "call_local", "reliable")	
func playerDeath() -> void:
	velocity = Vector2(0, 0)
	dead = true
	animated_sprite_2d.play("death")

@rpc("any_peer", "call_local", "reliable")
func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite_2d.animation == "death":
		get_tree().change_scene_to_file("res://scenes/ui/game_over.tscn")
		
func _on_health_changed(health) -> void:
	#hud.health = health
	health_bar.value = health
	if health < 0:
		pass
	


func _on_timer_timeout() -> void:
	var my_player_data = Game.get_current_player()
	if my_player_data.role == Statics.Role.MEDIC:
		stats.health += 10
		
	
func request_swap()-> void:
	if get_multiplayer_authority() == _swap_requester:
		return
	if not swap_timer.is_stopped():
		swap_equipment.rpc()
		
	else:
		for player_data in Game.players:
			if is_instance_valid(player_data.local_scene):
				player_data.local_scene.request_swap_local.rpc()
			
@rpc("any_peer","call_local")
func request_swap_local()-> void:
	if is_multiplayer_authority():
		swap_timer.start()
		swap_progress_bar.show()
		swap_progress_bar.max_value = swap_timer.wait_time
		_swap_requester = multiplayer.get_remote_sender_id()
		
@rpc("any_peer","call_local")		
func _on_swap_timer_timeout()-> void:
	_swap_requester = 0
	swap_progress_bar.hide()

@rpc("any_peer", "call_local")
func swap_equipment() -> void:
	var my_player_data = Game.get_player(get_multiplayer_authority())
	var other_player_data: Statics.PlayerData = null
	for player_data in Game.players:
		if player_data.id != get_multiplayer_authority():
			other_player_data = player_data
			break
	if my_player_data.equipment and other_player_data.equipment:
		var my_equipment = my_player_data.equipment
		var my_role = my_player_data.role
		my_player_data.equipment = other_player_data.equipment
		my_player_data.role = other_player_data.role
		
		other_player_data.equipment = my_equipment
		other_player_data.role = my_role
		remove_equipment()
		other_player_data.local_scene.remove_equipment()
		update_equipment()
		other_player_data.local_scene.update_equipment()
	other_player_data.local_scene.swap_timer.stop()
	other_player_data.local_scene._on_swap_timer_timeout()
	swap_timer.stop()
	_on_swap_timer_timeout()

func update_equipment() -> void:
	var player_data = Game.get_player(id)
	equipment = player_data.equipment
	for eq in equipment:
		eq.set_multiplayer_authority(id)
	spawn_current_equipment()
	
func remove_equipment()-> void:
	if equipment.size() > 0:
		for eq in equipment:
			remove_child(eq)
			
func spawn_current_equipment() -> void:
	for eq in equipment:
		add_child(eq)
