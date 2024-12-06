class_name  InputSynchronizer
extends MultiplayerSynchronizer


@export var directions := Vector2()
@export var jump := false
@export var shooting := false
@export var pause := false
@export var spam := false

func _physics_process(_delta: float) -> void:
	if is_multiplayer_authority():
		directions = Input.get_vector("left", "right", "up", "down" )

		if Input.is_action_just_pressed("jump"):
			jump_broadcast.rpc()
			
		if Input.is_action_just_pressed("click"):
			shoot_broadcast.rpc()
		
		if Input.is_action_just_pressed("pause"):
			pause_broadcast.rpc()
		
		if Input.is_action_pressed("click"):
			spam = true
			
		if Input.is_action_just_released("click"):
			spam=false
@rpc("call_local")
func jump_broadcast() -> void:
	jump = true
	
@rpc("call_local")	
func shoot_broadcast() -> void:
	shooting = true

@rpc("call_local")	
func pause_broadcast() -> void:
	pause = true

@rpc("call_local")	
func spam_broadcast() -> void:
	spam = true
	
@rpc("call_local")	
func spam_stop() -> void:
	spam = false
#@rpc("call_local")
#func swap_broadcast() -> void:
	#swap = true
