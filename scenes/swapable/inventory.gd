class_name Inventory
extends Node2D

signal swap_sign

@onready var client_id: int
@onready var current_id:int
@onready var player: Player = $Player
@onready var input_synchronizer: InputSynchronizer = $InputSynchronizer

@export var swap_intent := false



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if is_multiplayer_authority():
		if Input.is_action_just_pressed("swap"):
			if !swap_intent :
				swap_intent = true
				Debug.log("player: %s quiere hacer swap" % [current_id])
				swap_sign.emit(current_id)	
				
	else:
		swap_sign.connect(_on_swap_sign.bind())


func _on_swap_sign() -> void:
	Debug.log("player: %s recibio señal swap" % [current_id])
	if swap_intent:
		if current_id == 1:
			current_id = client_id
		else:
			current_id = 1
		set_multiplayer_authority(current_id)
		swap_weapon()
		swap_intent = false
		Debug.log("swap!!!")
			
func setup(current:int, client:int)->void:
	pass
	
func swap_weapon()->void:
	pass
