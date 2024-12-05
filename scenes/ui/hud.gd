@tool
class_name HUD
extends CanvasLayer 

@onready var health_bar: ProgressBar = $MarginContainer/HealthBar
@onready var label: Label = $MarginContainer2/Label

@export var health := 100 :
	set(value):
		health = value
		if health_bar:
			health_bar.value = health 

@export var role := "TEXT" :
	set(value):
		role = value
		if label:
			label.text = role
