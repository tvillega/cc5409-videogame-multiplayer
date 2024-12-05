class_name Chest
extends Area2D

@onready var label: Label = $Label
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var spawn_markers: Node2D = $SpawnMarkers


var player_inside: Player
var last_place: int
var picked: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	label.hide()
	animated_sprite_2d.play("default")
	
func _input(event: InputEvent)-> void:
	if player_inside and event.is_action_pressed("test"):
		pick()
		
func _process(delta: float) -> void:
	if picked:
		animated_sprite_2d.play("open")
		
		picked = false
	else: 
		animated_sprite_2d.play("default")
		
func setup(sp_marks: Node2D)->void:
	spawn_markers = sp_marks
	

func _on_animated_sprite_2d_animation_finished():
	if animated_sprite_2d.animation == "open":
		spawn()
		
func spawn()->void:
	var rand = randi()% 3
	while rand == last_place:
		Debug.log("sameplace")
		rand = randi()% 3
	last_place = rand
	Debug.log("respawning at: %s	" % (rand+1))
	
	global_position = spawn_markers.get_child(rand).global_position
	
func pick() -> void:
	Debug.log("pick")
	picked = !picked


func _on_body_entered(body: Node)-> void:
	var player = body as Player
	if player and player.is_multiplayer_authority():
		player_inside = player
		label.show()
	
func _on_body_exited(body: Node)-> void:
	if body == player_inside:
		player_inside = null
		label.hide()
