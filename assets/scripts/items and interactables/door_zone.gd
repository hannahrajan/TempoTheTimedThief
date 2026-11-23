extends Area2D

@onready var timer: Timer = $Timers/mov

var player: Node2D
# Check if the player is currently within interaction range.
var interacting: bool = false
var is_transitioning: bool = false

func _ready() -> void:
	$InteractArrow.visible = false
	timer.timeout.connect(_on_timer_timeout)

func _process(_delta: float) -> void:
	if is_transitioning and Input.is_action_pressed("interact"):
		return
	if interacting and Input.is_action_pressed("interact"):
		$InteractArrow.visible = false
		for body in get_overlapping_bodies():
			if body.name == "Player":
				start_transition(body)
				break

func start_transition(body: Node2D) -> void:
	is_transitioning = true
	player = body
	player.can_move = false
	player.is_transitioning = true
	
	AudioManager.play_enter_door()
	TransitionScene.transition()
	await TransitionScene.on_transition_finished
	
	player.is_transitioning = false
	body.global_position = $Marker2D.global_position
	timer.start(1.0)

func _on_timer_timeout() -> void:
	player.can_move = true
	is_transitioning = false

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		$InteractArrow.visible = true
		interacting = true
		
func _on_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		$InteractArrow.visible = false
		interacting = false
