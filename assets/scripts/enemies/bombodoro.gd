extends CharacterBody2D
class_name Bombodoro

var health: int = 2
var boom: bool = false
const BOOM_FRAME:= 9

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var hitflash_player: AnimationPlayer = $HitflashPlayer

func _on_sprite_2d_frame_changed() -> void:
	if $Sprite2D.frame == BOOM_FRAME:
		AudioManager.play_bombodoro_2()

func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.name == "Player" and boom != true:
		boom = true
		AudioManager.play_bombodoro_1()
		animation_player.play("Explode")
		
		# Remove this Bombodoro upon exploding. 
		await animation_player.animation_finished
		queue_free()

func _on_damage_area_area_entered(area: Area2D) -> void:
	if area.name == "Attack" or area.name == "DiveKick":
		if area.name == "DiveKick":
			area.get_parent().dive_bounce()
		hitflash_player.play("Hit Flash")
		health -= 1
		Hitstop.hitstop(0.05)
		if health <= 0:
			queue_free()
			AudioManager.play_enemy_death()
		else:
			AudioManager.play_enemy_damaged()
