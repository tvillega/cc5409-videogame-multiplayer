class_name Npc
extends CharacterBody2D

@onready var _animated_sprite : AnimatedSprite2D = $Sprite/AnimatedSprite2D

@export var speed = 200
@export var acceleration = 500
@export var player = null
@export var dead = false
var target: Node2D

@onready var detection_area: Area2D = $DetectionArea 
@onready var stats: Stats = $Stats

func _process(_delta):
	# Change sprite depending on what is going on
	if stats.health <= 0 and !dead: 
		npcDeath.rpc()
	if target:
		_animated_sprite.play("chase")
	else:
		_animated_sprite.play("idle")
@rpc("any_peer", "call_local", "reliable")	
func npcDeath() -> void:
	velocity = Vector2(0, 0)
	dead = true
	_animated_sprite.stop()
	self.queue_free()
func _ready() -> void:
	# Run detection area stuff (only inside server)
	
	#stats.health_changed.connect(_on_health_changed)
	if multiplayer.is_server():
		detection_area.body_entered.connect(_on_body_entered)
		detection_area.body_exited.connect(_on_body_exited)

func _physics_process(delta):
	# Start a chase towards the player
	if not dead:
		if target:
			var direction = global_position.direction_to(target.global_position)
			var distance = global_position.distance_to(target.global_position)
			# Don't glitch the player movement
			if distance > 50:
				velocity = velocity.move_toward(direction * speed, acceleration * delta)
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
		
