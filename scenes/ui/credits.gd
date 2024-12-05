extends MarginContainer

@export var title_color := Color.BLUE_VIOLET
@export var text_color := Color.WHITE
@export var title_font : FontFile = null
@export var text_font : FontFile = null
@export var Music : AudioStream = null
@export var Use_Video_Audio : bool = false
@export var Video : VideoStream = null

const section_time := 2.0
const line_time := 0.3
const base_speed := 70
const speed_up_multiplier := 10.0

var scroll_speed : float = base_speed
var speed_up := false

@onready var videoplayer := $VideoPlayer
@onready var line := $CreditsContainer/Line

var started := false
var finished := false

var section
var section_next := true
var section_timer := 0.0
var line_timer := 0.0
var curr_line := 0
var lines := []

var credits = [
	[
		"SHOOTER BUDDIES",
		"",
		"A game by Solarflare Fire"
	],[
		"Team Members",
		"",
		"Ignacio Arros - @Overplay45",
		"",
		"Martín Reyes - @MortanTheAndal",
		"",
		"Tomás Villegas - @tomas.villegas.m"
	],[
		"Art",
		"",
		"Tileset by Anokolisa",
		"",
		"https://anokolisa.itch.io/dungeon-crawler-pixel-art-asset-pack",
		"",
		"",
		"Menu Background by evan",
		"",
		"https://stock.adobe.com/search?k=%22dungeon+background%22&asset_id=549874832",
		"",
		"",
		"Evil Wizard by LuizMelo",
		"",
		"https://luizmelo.itch.io/evil-wizard",
		"",
		"",
		"Fireball particle effect by Lily Berry",
		"",
		"https://lilyberry03.itch.io/particle"
	],[
		"Music",
		"",
		"Martín Reyes"
	],[
		"Sound Effects",
		"",
		"Walking, dashing and sword SFX by TomMusic",
		"",
		"https://tommusic.itch.io/free-fantasy-200-sfx-pack",
		"",
		"",
		"Gun Sounds by SnakeF8",
		"",
		"https://f8studios.itch.io/snakes-authentic-gun-sounds",
		"",
		"",
		"Death Sounds by Michel Baradari",
		"",
		"https://opengameart.org/content/15-monster-gruntpaindeath-sounds",
		"",
		"https://opengameart.org/content/11-male-human-paindeath-sounds"
	],[
		"Tools used",
		"",
		"Developed with Godot Engine 4.3",
		"",
		"https://godotengine.org/license",
		"",
		"",
		"Music created with Maschine 3",
		"",
		"https://www.native-instruments.com/es/catalog/hardware/maschine/"
	],[
		"Special thanks",
		"",
		"Elías Zelada - Professor",
		"",
		"Joaquín Molina - Assistant Professor",
		"",
		"Amaro Zurita - Assistant Professor"
	]
]

func _ready():
	videoplayer.set_stream(Video)
	if !Use_Video_Audio:
		var stream = AudioStreamPlayer.new()
		stream.set_stream(Music)
		add_child(stream)
		videoplayer.set_volume_db(-80)
		stream.play()
	else:
		videoplayer.set_volume_db(0)
	videoplayer.play()
	

func _process(delta):
	scroll_speed = base_speed * delta
	
	if section_next:
		section_timer += delta * speed_up_multiplier if speed_up else delta
		if section_timer >= section_time:
			section_timer -= section_time
			
			if credits.size() > 0:
				started = true
				section = credits.pop_front()
				curr_line = 0
				add_line()
	
	else:
		line_timer += delta * speed_up_multiplier if speed_up else delta
		if line_timer >= line_time:
			line_timer -= line_time
			add_line()
	
	if speed_up:
		scroll_speed *= speed_up_multiplier
	
	if lines.size() > 0:
		for l in lines:
			l.set_global_position(l.get_global_position() - Vector2(0, scroll_speed))
			if l.get_global_position().y < l.get_line_height():
				lines.erase(l)
				l.queue_free()
	elif started:
		finish()


func finish():
	if not finished:
		finished = true
		get_tree().change_scene_to_file("res://scenes/lobby.tscn")


func add_line():
	var new_line = line.duplicate()
	new_line.text = section.pop_front()
	lines.append(new_line)
	if curr_line == 0:
		if title_font != null:
			new_line.set("theme_override_fonts/font", title_font)
		new_line.set("theme_override_colors/font_color", title_color)
	
	else:
		if text_font != null:
			new_line.set("theme_override_fonts/font", text_font)
		new_line.set("theme_override_colors/font_color", text_color)
	
	$CreditsContainer.add_child(new_line)
	
	if section.size() > 0:
		curr_line += 1
		section_next = false
	else:
		section_next = true


func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		finish()
	if event.is_action_pressed("ui_down") and !event.is_echo():
		speed_up = true
	if event.is_action_released("ui_down") and !event.is_echo():
		speed_up = false
