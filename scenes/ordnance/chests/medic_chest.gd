extends Chest


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
func pick(player_id:int)->void:
	if player_inside and player_inside.player.role == Statics.Role.MEDIC:
		super.pick(player_id)
		##player_inside.expand_equipment()
	
