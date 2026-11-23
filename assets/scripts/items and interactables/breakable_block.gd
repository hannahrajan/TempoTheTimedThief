extends Node2D
class_name BreakableBlock

# Explosion effect for when a block is destroyed.
var fx_bb = preload("res://assets/scenes/miscellaneous/effects/fx_breakable_block.tscn")

func _ready() -> void:
	match LevelManager.current_level:
		0:
			$Sprite2D.frame = 0
		1:
			$Sprite2D.frame = 1

# Upon being attacked by the player,
# the block enters its broken animation for 0.5 seconds
# and then disappears later.
func _on_check_for_attack_hitbox_area_entered(area: Area2D) -> void:
	if (
		area.name == "Attack"
		or area.name == "DiveKick"
		):
		# Player bounces off of block.
		if area.name == "DiveKick":
			area.get_parent().dive_bounce()
		
		# Screen shake with a factor of 5.
		area.get_parent().player_cam.start_shaking_that_thang(5.0)

		# Call destruction function.
		destroy()
		
func destroy() -> void:
		# Spawn break explosion effect.
		var boom = fx_bb.instantiate()
		boom.global_position = position	
		get_parent().call_deferred("add_child", boom)
		boom.play()
		
		# Play sound.
		AudioManager.play_break_block()
		
		# Destroy block.
		queue_free()
