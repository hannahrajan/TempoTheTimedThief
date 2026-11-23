extends CharacterBody2D

@onready var animator: AnimatedSprite2D = $AnimatedSprite2D
@onready var arrow: AnimatedSprite2D = $InteractArrow

# Check if the player is currently within interaction range.
var interacting: bool = false

func _ready() -> void:
	arrow.visible = false

func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		$InteractArrow.visible = true
		interacting = true
		
func _on_detection_area_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		$InteractArrow.visible = false
		interacting = false
