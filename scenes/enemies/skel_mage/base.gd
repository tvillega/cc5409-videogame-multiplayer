class_name SkelMage
extends EnemyMage

@onready var timer = %SpellTimer

func _ready() -> void:
	super._ready()
	timer.timeout.connect(_on_spell_timer_timeout)
	timer.start()
	%SpellShootingPoint.global_position += Vector2(1,1)
	
func _physics_process(delta):
	pass

func _on_spell_timer_timeout() -> void:
	if target:
		var projectile_scene = preload("res://scenes/enemies/skel_mage/fire_ball.tscn")
		var new_projectile = projectile_scene.instantiate()
		new_projectile.global_position = %SpellShootingPoint.global_position
		new_projectile.global_rotation = global_position.direction_to(target.global_position).angle()
		var world = get_tree().current_scene
		world.add_child(new_projectile)
		#add_child(new_projectile)
