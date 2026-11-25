class_name AttoHub
extends CharacterBody2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var arrow: AnimatedSprite2D = $InteractArrow

var player: Node2D
var timetable: Node2D
# Check if the player is currently within interaction range.
var interacting: bool = false
var is_transitioning: bool = false
var is_in_dialogue: bool = false

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
		
	timetable.send_scene_path.connect(_on_scene_chosen)
	
func _process(_delta: float) -> void:
	if is_transitioning or is_in_dialogue:
		return
	if Input.is_action_pressed("interact"):
		if is_in_dialogue:
			end_interaction()
		elif interacting:
			start_interaction()

func start_interaction() -> void:
	arrow.visible = false
	is_in_dialogue = true
	timetable.show()
	Dialogic.start("Atto_hub_world")

func end_interaction() -> void:
	timetable.hide()
	Dialogic.paused = false
	Dialogic.end_timeline()
	timetable.hide()
	is_in_dialogue = false
	if interacting:
		arrow.visible = true
		
func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		#SceneTransition.change_scene_to("res://assets/scenes/locations/tutorial-the_clock_tower.tscn")
		interacting = true
		if not is_in_dialogue:
			arrow.visible = true
		
func _on_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		arrow.visible = false
		interacting = false
		if is_in_dialogue:
			await end_interaction()
			Dialogic.start("Atto_hub_world", "show_scene")

# recieve the scene chosen through the time table!
# this will eventually be used to dictate what the level is.
func _on_scene_chosen(scene: String) -> void:
	if not is_in_dialogue or scene.is_empty():
		return

	timetable.hide()
	# this is just to demo the scene path updates and sends info to Dialogic!
	Dialogic.VAR.set_variable("SceneInfo.scene", scene)
