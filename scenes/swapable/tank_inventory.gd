class_name TankInventory
extends Inventory

@onready var shotgun: Shotgun = $Shotgun

func setup(sserver_player: Player, cclient_player: Player) -> void:
	player = cclient_player
	server_player = sserver_player
	client_player = cclient_player
	set_multiplayer_authority(player.id)
	shotgun.set_multiplayer_authority(player.id)
	SignalHandler.medic_wants_swap.connect(_on_medic_wants_swap)
	
func _process(delta: float) -> void:
	if is_multiplayer_authority():
		global_position = player.global_position
		if Input.is_action_pressed("swap"):
			
			if !self.swap_intent :
				Debug.log("player %s intenta swap"% [player.id])
				self.swap_intent = true
				Debug.log("player %s emite señal"% [player.id])
				SignalHandler.tank_wants_swap.emit()
				Debug.log("player %s espera swap"% [player.id])
				
		
				
func swap_weapon()->void:
	set_multiplayer_authority(player.id)
	shotgun.set_multiplayer_authority(player.id)
	
func _on_medic_wants_swap() -> void:
	Debug.log("player: %s recibio señal swap" % [player.id])
	if swap_intent:
		if player.id == 1:
			player = client_player
		else: 
			player=server_player
		swap_weapon()
		swap_intent = false
		Debug.log("swap!!!")
