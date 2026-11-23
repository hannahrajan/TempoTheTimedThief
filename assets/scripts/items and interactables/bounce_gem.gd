extends Node2D

var hit: bool = false

@onready var hitbox: CollisionShape2D = $CheckForAttackHitbox/CollisionShape2D
@onready var particles: AnimatedSprite2D = $Particles

var fx_bgb = preload("res://assets/scenes/miscellaneous/effects/fx_bounce_gem_burst.tscn")

func _on_check_for_attack_hitbox_area_entered(area: Area2D) -> void:
	if (
		area.name == "Attack"
		or area.name == "Air Attack"
		or area.name == "DiveKick"
		and hit == false
		):
		
		# Spawn break explosion effect.
		var burst = fx_bgb.instantiate()
		burst.global_position = position	
		get_parent().call_deferred("add_child", burst)
		burst.play()
		
		#AudioManager.play_bounce_gem()
		hit = true
		hitbox.set_deferred("disabled", true)
		$Sprite2D.frame = 1
		$Particles.stop()
		$Timer.start()
			
		# Player bounces off of block.
		if area.name == "DiveKick":
			area.get_parent().dive_bounce()

func _on_timer_timeout() -> void:
	hit = false
	hitbox.set_deferred("disabled", false)
	$Particles.play()
	$Sprite2D.frame = 0
