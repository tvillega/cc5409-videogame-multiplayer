extends Chest


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
func pick()->void:
	if player_inside and player_inside.player.role == Statics.Role.MEDIC:
		super.pick()
		##player_inside.expand_equipment()
	
