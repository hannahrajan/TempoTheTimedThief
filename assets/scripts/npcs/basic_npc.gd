extends CharacterBody2D

# Left = -1, Right = +1
var direction: int = -1
#============================================================================
@onready var arrow: AnimatedSprite2D = $InteractArrow
@onready var move_timer: Timer = $Timers/MoveTimer
@onready var cooldown_timer: Timer = $Timers/MoveCooldownTimer
#============================================================================
# Toggleable in the Inspector: Change AnimatedSprite2D resource based on this.
@export var type: String
# Toggleable in the Inspector: Allow NPC to move randomly left to right.
@export var unlock_move: bool = false
var can_move_atm: bool = false
# Speed at which an NPC that can move according to "move" moves.
@export var set_speed: int = 0
var SPEED: int = 0
#============================================================================
# Check if the player is currently within interaction range.
var interacting: bool = false
# References the selected sprite.
var mySprite: AnimatedSprite2D
#============================================================================
#============================================================================
#============================================================================
# Match sprite depending on what "type" was specified to be.
# The position of InteractArrow also changes to float above
# the chosen sprite's head properly.
func chooseSprite():

	match type:
		"AttoAcolyte":
			$Sprites/AttoAcolyte.visible = true
			mySprite = $Sprites/AttoAcolyte
			$InteractArrow.position = Vector2(0.0, -43.0)
		"AttoDevotee":
			$Sprites/AttoDevotee.visible = true
			mySprite = $Sprites/AttoDevotee
			$InteractArrow.position = Vector2(0.0, -55.0)
		"AttoApostle":
			mySprite = $Sprites/AttoApostle
			$Sprites/AttoApostle.visible = true
			$InteractArrow.position = Vector2(0.0, -51.0)
	
	# Hide all unselected sprites.
	for sprite in $Sprites.get_children():
		if sprite != mySprite:
			sprite.visible = false
#============================================================================
# Ready.
func _ready() -> void:
	# Arrow should only be visible when the player is within
	# interaction range.
	arrow.visible = false
	
	# Choose sprite to display.
	chooseSprite()
	
	# The interval in which an NPC moves should be a little random.
	if unlock_move == true:
		SPEED = set_speed
		can_move_atm = true
		move_timer.start()
#============================================================================
# Flip sprite according to direction.
func _process(delta: float) -> void:
	if can_move_atm == true:
		for sprite in $Sprites.get_children():
				if sprite == mySprite:
					if direction == -1:
						sprite.flip_h = false
					else:
						sprite.flip_h = true
#============================================================================
func _physics_process(delta: float) -> void:
	if can_move_atm == true:
		position.x += direction * SPEED * delta
#============================================================================
# When the move timer times out, halt speed to stop NPC movement.
# Start cooldown timer.
func _on_move_timer_timeout() -> void:
	can_move_atm = false
	SPEED = 0
	
	cooldown_timer.start()
#============================================================================
# When the cooldown timer times out, resume NPC movement in the direction
# opposite of its previous movement. Start move timer.
func _on_move_cooldown_timer_timeout() -> void:
	can_move_atm = true
	direction = direction * -1
	SPEED = set_speed
	
	move_timer.start()
#============================================================================					
# Check for interaction range.
func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		$InteractArrow.visible = true
		interacting = true	
func _on_detection_area_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		$InteractArrow.visible = false
		interacting = false
