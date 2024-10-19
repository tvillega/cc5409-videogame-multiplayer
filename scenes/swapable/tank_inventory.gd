class_name TankInventory
extends Inventory


@onready var shotgun: Shotgun = $Shotgun

func setup(player_id: int, client_id: int) -> void:
	current_id = player_id
	client_id = client_id
	set_multiplayer_authority(current_id)
	input_synchronizer.set_multiplayer_authority(current_id)
	player.set_multiplayer_authority(current_id)
	shotgun.set_multiplayer_authority(current_id)
		
func swap_weapon()->void:
	input_synchronizer.set_multiplayer_authority(current_id)
	shotgun.set_multiplayer_authority(current_id)
