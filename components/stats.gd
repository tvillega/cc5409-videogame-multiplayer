class_name Stats
extends Node

signal health_changed(health)
signal role_changed(role)

@export var health := 100 :
	set(value):
		health = clamp(value, 0, max_health)
		health_changed.emit(health)
@export var max_health := 100

@export var role := 0 :
	set(value):
		role = value
		role_changed.emit(role)
