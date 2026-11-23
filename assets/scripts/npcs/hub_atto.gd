class_name AttoHub
extends CharacterBody2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var arrow: AnimatedSprite2D = $InteractArrow

var player: Node2D
var timetable: Node2D
# Check if the player is currently within interaction range.
var interacting: bool = false
var is_transitioning: bool = false

func _ready() -> void:
	
	sprite.play("Idle")
	
	arrow.visible = false
	
	for child in get_children():
		if child is TimeTable:
			timetable = child
			break
	
	# if timetable doesn't exist yet, we wait for it to be created...
	if not timetable:
		while true:
			var child = await child_entered_tree
			if child is TimeTable:
				timetable = child
				break
	
	#...then initialized.
	if not timetable.is_node_ready():
		await timetable.ready
		
	scene_chosen()
	
func _process(_delta: float) -> void:
	if is_transitioning and Input.is_action_pressed("interact"):
		return
	if interacting and Input.is_action_pressed("interact"):
		arrow.visible = false
		timetable.show()
	if not interacting and Input.is_action_just_pressed("interact"):
		arrow.visible = true
		scene_chosen()
	
func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		#SceneTransition.change_scene_to("res://assets/scenes/locations/tutorial-the_clock_tower.tscn")
		$InteractArrow.visible = true
		interacting = true
		
func _on_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		$InteractArrow.visible = false
		interacting = false
		scene_chosen()

# recieve the scene chosen through the time table!
# this will eventually be used to dictate what the level is.
func scene_chosen() -> void:
	timetable.hide()
	var scene = await timetable.send_scene_path
	print(scene) # this is just to demo the scene path updates!
