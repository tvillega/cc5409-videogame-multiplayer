extends Chest

@export var machinegun_scene: PackedScene
@export var granade_scene: PackedScene

@export var counter = 0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func pick()->void:
	if player_inside and player_inside.player.role == Statics.Role.TANK:
		player_inside.expand_equipment(machinegun_scene.instantiate())
		super.pick()
		
