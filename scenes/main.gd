extends Node2D

@export var player_scene: PackedScene
@export var medic_chest_scene: PackedScene
@export var tank_chest_scene: PackedScene


@onready var players: Node2D = $Players
@onready var chests: Node2D = $Chests

@onready var markers: Node2D = $PlayersSpawnMarker
@onready var chest_spawn_markers: Node2D = $ChestSpawnMarkers
@onready var chest_spawn_markers_tank: Node2D = $ChestSpawnMarkersTank

func _ready() -> void:
	var med_chest_inst = medic_chest_scene.instantiate()
	var tank_chest_inst = tank_chest_scene.instantiate()
	chests.add_child(tank_chest_inst)
	chests.add_child(med_chest_inst)
	tank_chest_inst.setup(chest_spawn_markers)
	med_chest_inst.setup(chest_spawn_markers_tank)
	tank_chest_inst.spawn()
	med_chest_inst.spawn()
	for i in Game.players.size():
		var player_data = Game.players[i]
		var player_inst = player_scene.instantiate()
		
		
		players.add_child(player_inst)
		player_inst.setup(player_data)
		
		
		player_inst.global_position = markers.get_child(i).global_position
		player_data.local_scene = player_inst
		
	
