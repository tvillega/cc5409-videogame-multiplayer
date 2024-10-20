class_name Stats
extends Node

@export var health := 100 :
	set(value):
		health = clamp(value, 0, max_health)
@export var max_health := 100


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
