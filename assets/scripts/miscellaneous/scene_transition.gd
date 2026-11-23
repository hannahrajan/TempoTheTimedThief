extends CanvasLayer

@onready var color_rect: ColorRect = $ColorRect

# The path of the scene we want to load/switch to.
var scene_to_load: String
# This holds the Tween that will animate the level transition visual.
var color_rect_tween: Tween

# Calling this activates the animation.
func change_scene_to(scene_path: String) -> void:
	# If a tween is currently active:
	if color_rect_tween:
		# Kill the current tween and replace it with a new one.
		color_rect_tween.kill()
	# Designates the next scene to be loaded as the scene path.
	scene_to_load = scene_path
	
	# Pause the game while the transition runs.
	get_tree().paused = true
	
	# Create the tween.
	color_rect_tween = create_tween().set_trans(Tween.TRANS_SINE)
	# Take the Color Rect, modulate the alpha value to 1.0 (transparent to opaque)
	# over the course of 0.2 seconds.
	# When the tween is completed, the new scene is loaded in.
	color_rect_tween.tween_property(color_rect, "modulate:a", 1.0, 0.2).connect("finished", _load_new_scene)
	# Now, we return the tween to transparency by setting the alpha to 0.0.
	# It's important to use chain() here to ensure this line runs AFTER
	# the previous tween_property function.
	color_rect_tween.chain().tween_property(color_rect, "modulate:a", 0.0, 0.4)

# Activates when the fade-in animation completes.
# The game then loads the new scene, then the animation fades out.
func _load_new_scene() -> void:
	get_tree().paused = false		# Unpause the game once the transition is finished.
	get_tree().call_deferred("change_scene_to_file", scene_to_load)
