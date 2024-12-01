class_name BossWizard
extends CharacterBody2D

@onready var _animated_sprite : AnimatedSprite2D = $Sprite/AnimatedSprite2D

@export var speed = 200
@export var acceleration = 500
@export var player = null
@export var dead = false
var target: Node2D

@onready var detection_area: Area2D = $DetectionArea 
@onready var stats : BossWizardStats = $BossStats
@onready var health_bar = $HealthBar

@export var heal_animation = false


func _process(_delta):
	# Change sprite depending on what is going on
	if stats.health <= 0 and !dead: 
		npcDeath.rpc()
	
	elif target:
		
		if velocity.x < 0:
			_animated_sprite.flip_h = true
		elif velocity.x > 0:
			_animated_sprite.flip_h = false
			
		var distance = global_position.distance_to(target.global_position)

		if !dead:
			if heal_animation:
				velocity = Vector2(0,0)
				_animated_sprite.play("heal")
			elif distance < 100 and !heal_animation:
				_animated_sprite.play("attack")
			else:
				_animated_sprite.play("chase")
					
	else:
		if !dead: _animated_sprite.play("idle")

@rpc("any_peer", "call_local", "reliable")	
func npcDeath() -> void:
	velocity = Vector2(0, 0)
	dead = true
	_animated_sprite.play("death")

func _on_animated_sprite_2d_animation_finished():
	if _animated_sprite.animation == "death":
		self.queue_free()

func _ready() -> void:
	
	stats.health_changed.connect(_on_health_changed)
	#hud.health = stats.health
	#hud.visible = is_multiplayer_authority()
	health_bar.value = stats.health
	# Run detection area stuff (only inside server)
	
	#stats.health_changed.connect(_on_health_changed)
	if multiplayer.is_server():
		detection_area.body_entered.connect(_on_body_entered)
		detection_area.body_exited.connect(_on_body_exited)

func _on_health_changed(health) -> void:
	#hud.health = health
	health_bar.value = health
	if health < 0:
		pass

func _physics_process(delta):
	# Start a chase towards the player
	if not dead:
		if target:
			var target_player = target as Player
			var target_player_data = Game.get_player(target_player.id)
			var _sign = 1
			#if target_player_data.role == Statics.Role.MEDIC:
			#	_sign = -1
			var direction = global_position.direction_to(target.global_position)
			var distance = global_position.distance_to(target.global_position)
			# Don't glitch the player movement
			if distance > 50:
				velocity = velocity.move_toward(direction * speed*_sign, acceleration * delta)
				move_and_slide()
	
###
### This sets the chase target i.e. the player
###
func _on_body_entered(body: Node) -> void:
	var player = body as Player
	if player:
		set_target(player)
		
func _on_body_exited(body: Node) -> void:
	if body == target:
		set_target(null)

func set_target(value: Node2D) -> void:
	target = value
	var path = target.get_path() if target else null
	set_target_remote.rpc(path if path else null)

@rpc("any_peer", "reliable")
func set_target_remote(target_path):
	if target_path:
		target = get_node(target_path)
	else:
		target = null

##
## This functions are called through signals by other entities
##
func take_damage(damage: int):
	# Avoid sending text twice
	stats.health -= damage
	if multiplayer.is_server():
		Debug.log("NPC says auch! remaining health -%d" % stats.health)

func _on_stop_heal_timer_timeout() -> void:
	stats.health += 500
	health_bar.value = stats.health
	heal_animation = false

func _on_start_heal_timer_timeout() -> void:

	heal_animation = true
	Debug.log("BOSS WIzzard HEAling!")
