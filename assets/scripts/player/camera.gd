extends Camera2D

#============================================================================
# Lookahead camera.
# Shifts the camera ahead of Tempo in the direction he's moving,
# so the player can see more of what's coming.
#============================================================================

@export var lookahead_distance: float = 40.0	# How far ahead (in pixels) the camera shifts.
@export var lookahead_speed: float = 2.0		# How quickly the camera eases toward the lookahead point.
@export var min_speed: float = 20.0				# Tempo must move faster than this to change the look direction.
@export var turn_delay: float = 0.3				# Seconds Tempo must keep moving the new way before the camera turns.

# Vertical deadzone (fraction of half the screen height).
# Tempo can move this far up/down before the camera follows,
# so small hops don't bob the camera.
@export var deadzone_top: float = 0.25
@export var deadzone_bottom: float = 0.1

# Reference to the player (the camera's parent).
@onready var player: CharacterBody2D = get_parent()

# The direction the camera is currently looking ahead (-1 = left, 1 = right).
var look_dir: float = 1.0
# How long Tempo has been moving opposite to the current look direction.
var turn_timer: float = 0.0


@export var shake_fade: float = 10.0
# Strength of the camera shaking, decreases over time.
var _shake_strength: float = 0.0

func _ready() -> void:
	drag_vertical_enabled = true
	drag_top_margin = deadzone_top
	drag_bottom_margin = deadzone_bottom
	add_to_group("camera")

# Call this function from other places that want to trigger a screen shake.
func start_shaking_that_thang(max_shake: int) -> void:
	_shake_strength = max_shake

# Dictates screen shaking.
func _process(delta: float) -> void:
	if _shake_strength > 0:
		_shake_strength = lerp(_shake_strength, 0.0, shake_fade * delta)
		offset = Vector2(
			randf_range(-_shake_strength, _shake_strength), 
			randf_range(-_shake_strength, _shake_strength)
			)

# The camera's process callback is set to Physics,
# so update alongside the player's movement to avoid jitter.
func _physics_process(delta: float) -> void:
	# Only consider turning when moving fast enough,
	# so the camera holds its position when Tempo stops.
	if abs(player.velocity.x) > min_speed and sign(player.velocity.x) != look_dir:
		# Deadzone for turning: Tempo has to keep moving the new way
		# for a moment before the camera commits to turning around.
		turn_timer += delta
		if turn_timer >= turn_delay:
			look_dir = sign(player.velocity.x)
			turn_timer = 0.0
	else:
		turn_timer = 0.0

	# Ease the camera offset toward the lookahead point.
	var target_x: float = look_dir * lookahead_distance
	offset.x = lerp(offset.x, target_x, 1.0 - exp(-lookahead_speed * delta))
