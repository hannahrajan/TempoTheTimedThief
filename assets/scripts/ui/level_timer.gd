extends Node2D

@onready var leveltimer: Timer = $Timer
@onready var timerlabel: Label = $Label
@onready var heart: Sprite2D = $Sprite2D
# Indicators for single screen-shakes.
var minute_left: bool = false
var thirty_left: bool = false
var ten_left: bool = false


func _ready() -> void:
	add_to_group("level_timer")
	
	$Label.visible = true
	
	# Initial amount of time differs based on level.
	match LevelManager.current_level:
		100:
			$Label.visible = false
			heart.frame = 0
		0:
			leveltimer.start(360)
		1:
			leveltimer.start(5)
		2:
			leveltimer.start(360)

	timerlabel.text = "%.1f" % leveltimer.time_left
	

func _process(_delta: float) -> void:
	timerlabel.text = "%.1f" % leveltimer.time_left
	
	# Danger indicators based on time left (screen shake, heart HUD).
	if 31 <= leveltimer.time_left and leveltimer.time_left <= 60:
		heart.frame = 1
		if minute_left == false:
			minute_left = true
			var player = get_tree().get_first_node_in_group("player")
			player.player_cam.start_shaking_that_thang(25.0)
	if 11 <= leveltimer.time_left and leveltimer.time_left <= 30:
		heart.frame = 2
		if thirty_left == false:
			thirty_left = true
			var player = get_tree().get_first_node_in_group("player")
			player.player_cam.start_shaking_that_thang(50.0)
	if 0 <= leveltimer.time_left and leveltimer.time_left <= 10:
		heart.frame = 3
		if ten_left == false:
			ten_left = true
			var player = get_tree().get_first_node_in_group("player")
			player.player_cam.start_shaking_that_thang(100.0)	
	# Reset danger indicators.
	if leveltimer.time_left > 61:
		heart.frame = 0
		minute_left = false
		thirty_left = false
		ten_left = false

func _on_timer_timeout():
	var player = get_tree().get_first_node_in_group("player")
	if is_instance_valid(player):
		player.die()

func remove_time(time):
	var new_time = leveltimer.time_left - time
	if new_time > 0:
		leveltimer.start(new_time)
	else:
		leveltimer.start(0.000001)
	
