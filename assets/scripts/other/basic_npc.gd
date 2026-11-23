extends CharacterBody2D

class_name BasicNPC

@export var dialogue: String

var interacting: bool = false

func _ready() -> void:
	$InteractArrow.visible = false

func _process(delta: float) -> void:
	if (
		interacting
		and Input.is_action_just_pressed("interact")
		):
			interacting = false
			$InteractArrow.visible = false
			converse()

func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		$InteractArrow.visible = true
		interacting = true

func _on_detection_area_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		$InteractArrow.visible = false
		interacting = false
		
func converse() -> void:
	var timer = get_tree().get_first_node_in_group("level_timer")
	timer.leveltimer.stop()
	SceneTransition.change_scene_to("res://assets/scenes/locations/hub_world.tscn")
