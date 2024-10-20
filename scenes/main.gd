extends Node2D

@export var player_scene: PackedScene
@onready var players: Node2D = $Players
@onready var markers: Node2D = $Markers
@onready var inventories: Node2D = $Inventories

#@onready var npc: Node2D = $npc

func _ready() -> void:
	var server_player: Player
	var client_player: Player
	for i in Game.players.size():
		
		#leo datos e inicio jugador
		var player_data = Game.players[i]
		var player_inst = player_scene.instantiate()
		#players.add_child(player_inst)
		#inicio inventarios
		var INV
		var pos = markers.get_child(i).global_position
		if player_data.id == 1:
			server_player = player_inst
			INV = preload("res://scenes/swapable/medic_inventory.tscn")
		else:
			client_player = player_inst
			INV = preload("res://scenes/swapable/tank_inventory.tscn")
			
		var inv_inst = INV.instantiate()
		inventories.add_child(inv_inst)
		#jugadores son hijos de inventario
		inv_inst.add_child(player_inst)
		player_inst.setup(player_data)
		player_inst.global_position = pos
		#inv_inst.global_position = pos
	for inv in inventories.get_children():
		inv.setup(server_player,client_player)
		
		
