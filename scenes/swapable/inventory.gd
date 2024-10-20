class_name Inventory
extends Node2D



@onready var player: Player = $Inventories/Player


@onready var swap_intent := false
@export var client_player: Player
@export var server_player: Player

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


			
func setup(server:Player, client:Player)->void:
	pass
	
func swap_weapon()->void:
	pass
