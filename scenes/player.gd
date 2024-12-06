class_name Player
extends CharacterBody2D

@export var speed = 400
@export var jump_speed = 6000
@export var acceleration = 1000
@export var is_tank = true
@export var dead = false
@export var foot_sound_1: AudioStream
@export var foot_sound_2: AudioStream
@export var foot_sound_3: AudioStream
@export var dash_sound: AudioStream
@export var damage_sound: AudioStream
@export var death_sound: AudioStream
@export var equipment : Array[Node2D]
@export var healing_factor = 20

@export var pistol_scene : PackedScene
@export var shotgun_scene : PackedScene


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

@onready var stats = $Stats
#@onready var hud: HUD = $HUD
@onready var health_bar = $HealthBar
@onready var Role: Label = $Role
@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var sound_timer: Timer = $SoundTimer
@onready var swap_timer: Timer = $SwapTimer
@onready var swap_progress_bar: ProgressBar = $SwapProgressBar
@onready var weapons: Node2D = $weapons

var movement_orient = ""

func _ready() ->  void:	
	stats.health_changed.connect(_on_health_changed)
	stats.role_changed.connect(_on_role_changed)
	#hud.health = stats.health
	#hud.visible = is_multiplayer_authority()
	health_bar.value = stats.health
	Role.text = str(stats.role)
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
			AudioManager.play_stream(dash_sound, -15)
		input_synchronizer.jump = false

#		if input_synchronizer.swap:
#			if is_tank:
#				is_tank = false
#				remove_child(pistol)
#				add_child(shotgun)
#			else:
#				is_tank = true
#				remove_child(shotgun)
#				add_child(pistol)
#		input_synchronizer.swap = false

		if velocity.length() != 0:
			if sound_timer.time_left <= 0:
				foot_fx()
				sound_timer.start(0.4)
		if is_multiplayer_authority():
			if Input.is_action_just_pressed("swap"):
				request_swap()
				
			if Input.is_action_just_pressed("equipo1"):
				spawn_current_equipment.rpc(0)
				
			if Input.is_action_just_pressed("equipo2"):
				Debug.log("toggle weapon// size %s" % weapons.equipment.size())
				spawn_current_equipment.rpc(1)
	move_and_slide()


func setup(player_data: Statics.PlayerData) -> void:
	name = str(player_data.id)
	set_multiplayer_authority(player_data.id)
	
	if player_data.role == Statics.Role.MEDIC: 
		Role.text = "Medic"
		var pistol = pistol_scene.instantiate()
		pistol.setup(player_data.id)
		#player_data.equipment.append(pistol)
		weapons.equipment.append(pistol)
		weapons.add_child(pistol)

	else: 
		Role.text = "Tank"
		var shotgun = shotgun_scene.instantiate()
		shotgun.setup(player_data.id)
		#player_data.equipment.append(shotgun)
		weapons.equipment.append(shotgun)
		weapons.add_child(shotgun)
	
	input_synchronizer.set_multiplayer_authority(player_data.id)
	multiplayer_synchronizer.set_multiplayer_authority(player_data.id)

	label.text = player_data.name
	id = player_data.id
	player = player_data
	camera_2d.enabled = is_multiplayer_authority()
	update_equipment(0)	


@rpc("authority", "call_remote", "unreliable")
func test():
	pass


func pauseMenu():
	if paused:
		pause_menu.hide()
	else:
		pause_menu.show()
		
	
	paused = !paused

@rpc("any_peer", "call_local", "reliable")	
func take_damage(damage: int) -> void:
	#notify_take_damage.rpc_id(get_multiplayer_authority(), damage)
	stats.health -= damage
	AudioManager.play_stream(damage_sound)
	# Avoid sending text twice
	if multiplayer.is_server():
		Debug.log("Player says auch! -%d" % damage)
		Debug.log("Player health at %d" % stats.health)

@rpc("any_peer", "call_local", "reliable")	
func playerDeath() -> void:
	AudioManager.play_stream(death_sound, -15, randf_range(0.9, 1.1))
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
		
func _on_role_changed(role) -> void:
	#hud.health = health
	if role == 1:
		Role.text = "Tank"
	else:
		Role.text = "Medic"
	
func _on_timer_timeout() -> void:
	var my_player_data = Game.get_current_player()
	if Role.text == "Medic":
		stats.health += healing_factor
		
func foot_fx() -> void:
	var luck = randi_range(1, 3)
	if luck == 1:
		AudioManager.play_stream(foot_sound_1, -15, randf_range(0.7, 1.3))
	elif luck == 2:
		AudioManager.play_stream(foot_sound_2, -15, randf_range(0.7, 1.3))
	else:
		AudioManager.play_stream(foot_sound_3, -15, randf_range(0.7, 1.3))
		
	
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
			
			
	if weapons.equipment and other_player_data.local_scene.weapons.equipment:
		Debug.log("weapon eq size %s" % weapons.equipment.size())
		#var my_equipment = my_player_data.equipment
		var my_role = my_player_data.role
		var my_weapons_equipment = weapons.equipment
		remove_equipment()
		other_player_data.local_scene.remove_equipment()
		weapons.equipment = other_player_data.local_scene.weapons.equipment
		my_player_data.role = other_player_data.role
		stats.role = my_player_data.role
		other_player_data.local_scene.weapons.equipment = my_weapons_equipment
		other_player_data.role = my_role
		other_player_data.local_scene.stats.role = my_role
		#other_player_data.equipment = my_equipment
		
		update_equipment.rpc(0)
		other_player_data.local_scene.update_equipment.rpc(0)
		
	other_player_data.local_scene.swap_timer.stop()
	other_player_data.local_scene._on_swap_timer_timeout()
	swap_timer.stop()
	_on_swap_timer_timeout()
@rpc("any_peer","call_local", "reliable")
func update_equipment(index) -> void:
	var player_data = Game.get_player(id)
	for eq in weapons.equipment:
		eq.set_multiplayer_authority(id)
	spawn_current_equipment(index)
	
func remove_equipment()-> void:
	if weapons.equipment.size() > 0:
		for eq in weapons.equipment:
			weapons.remove_child(eq)

@rpc("any_peer","call_local", "reliable")
func spawn_current_equipment(index:int) -> void:
	if index >= weapons.equipment.size():
		var weapon = weapons.equipment[weapons.equipment.size()-1]
		remove_equipment()
		weapons.add_child(weapon)
	
		
	else:
		var weapon = weapons.equipment[index]
		remove_equipment()
		weapons.add_child(weapons.equipment[index])
		
	
@rpc("authority","call_local","reliable")
func expand_equipment(ide: int )->void:
	var scene = Game.weapons[ide]
	var mg_inst = scene.instantiate()
	mg_inst.setup(player.id)
	weapons.equipment.append(mg_inst)
	update_equipment(weapons.equipment.size()-1)

	
	
