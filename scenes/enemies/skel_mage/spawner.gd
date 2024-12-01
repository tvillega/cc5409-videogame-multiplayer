extends MultiplayerSpawner

@onready var marker_2d: Marker2D = $SkelSpawnerMarker
@onready var timer: Timer = $Timer
@export var enemy_scene: PackedScene
@export var count = 0

func _ready() -> void:
	#if multiplayer.is_server():
	if enemy_scene:
		timer.timeout.connect(on_timer_timeout)
			
func on_timer_timeout() -> void:
	if not enemy_scene:
		return
	var enemy_inst = enemy_scene.instantiate()
	count+=500
	enemy_inst.global_position = marker_2d.global_position + Vector2(sin((PI * count) / 30) * 20 / 2 * PI, sin((PI * count) / 30) * 20 / 2 * PI)
	count = count%5000
	add_child(enemy_inst, true)
