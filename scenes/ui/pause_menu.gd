extends Control

@export var player_id : int = -1
@onready var pause_synchronizer: InputSynchronizer = $InputSynchronizer
@onready var player = $"../../"

func setup(id: int)-> void:
	player_id = id
	set_multiplayer_authority(id)

func _on_resume_pressed() -> void:
	player.pauseMenu()

func _on_quit_pressed() -> void:
	#if is_multiplayer_authority():
	get_tree().quit()
