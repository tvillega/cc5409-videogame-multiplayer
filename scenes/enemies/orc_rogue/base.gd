class_name OrcRogue
extends EnemyRogue

@export var npc_death: AudioStream

@rpc("any_peer", "call_local", "reliable")	
func npcDeath() -> void:
	AudioManager.play_stream(npc_death, -15, randf_range(0.8, 1.2))
	velocity = Vector2(0, 0)
	dead = true
	_animated_sprite.play("death")
