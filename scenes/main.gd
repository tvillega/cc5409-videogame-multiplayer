extends Node2D

@export var player_scene: PackedScene
@onready var players: Node2D = $Players
@onready var markers: Node2D = $Markers
@onready var inventories: Node2D = $Inventories

#@onready var npc: Node2D = $npc

func _ready() -> void:
	var client_id: int
	for i in Game.players.size():
		var player_data = Game.players[i]
		var player_inst = player_scene.instantiate()
		players.add_child(player_inst)

		player_inst.setup(player_data)
		if player_inst.id != 1:
			client_id = player_inst.id
		player_inst.global_position = markers.get_child(i).global_position
		
		
	for pl in players.get_children(): 
		var INV
		var pos
		if pl.id == 1:
			INV = preload("res://scenes/swapable/medic_inventory.tscn")
			pos = markers.get_child(0).global_position
		else:
			INV = preload("res://scenes/swapable/tank_inventory.tscn")
			pos = markers.get_child(1).global_position
		var inv_inst = INV.instantiate()
		inventories.add_child(inv_inst)
		inv_inst.setup(pl.id, client_id)
		inv_inst.global_position = pos
