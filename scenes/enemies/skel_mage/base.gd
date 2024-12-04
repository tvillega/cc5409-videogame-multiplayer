class_name SkelMage
extends EnemyMage

@onready var timer = %SpellTimer

func _ready() -> void:
	super._ready()
	timer.timeout.connect(_on_spell_timer_timeout)
	timer.start()
	%SpellShootingPoint.global_position += Vector2(1,1)

func _on_spell_timer_timeout() -> void:
	var projectile_scene = preload("res://scenes/enemies/skel_mage/fire_ball.tscn")
	var new_projectile = projectile_scene.instantiate()
	new_projectile.global_position = %SpellShootingPoint.global_position
	var world = get_tree().current_scene
	world.add_child(new_projectile)
	#add_child(new_projectile)
