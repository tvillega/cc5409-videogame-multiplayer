class_name SkelMage
extends EnemyMage

@export var npc_death: AudioStream

@onready var timer = %SpellTimer

func _ready() -> void:
	super._ready()
	timer.timeout.connect(_on_spell_timer_timeout)
	timer.start()
	%SpellShootingPoint.global_position += Vector2(1,1)
	
func _physics_process(delta):
	
	if target:
		var direction = global_position.direction_to(target.global_position)
		var my_velocity = velocity.move_toward(direction * speed, acceleration * delta)
	
		if my_velocity.x < 0:
			_animated_sprite.flip_h = true
		elif my_velocity.x > 0:
			_animated_sprite.flip_h = false
	
@rpc("any_peer", "call_local", "reliable")	
func npcDeath() -> void:
	AudioManager.play_stream(npc_death, -15, randf_range(0.8, 1.2))
	velocity = Vector2(0, 0)
	dead = true
	_animated_sprite.play("death")

func _on_spell_timer_timeout() -> void:
	if target:
		var projectile_scene = preload("res://scenes/enemies/skel_mage/fire_ball.tscn")
		var new_projectile = projectile_scene.instantiate()
		new_projectile.global_position = %SpellShootingPoint.global_position
		new_projectile.global_rotation = global_position.direction_to(target.global_position).angle()
		var world = get_tree().current_scene
		world.add_child(new_projectile)
		#add_child(new_projectile)
