extends Node2D

@onready var AP: AnimationPlayer = $AnimationPlayer

var in_range: bool = false

func _on_detection_area_body_entered(body: Node2D) -> void:
	if in_range == true:
		pass
	if body.name == "Player" and in_range == false:
		in_range = true
		AP.play("Charging")

func _on_detection_area_body_exited(body: Node2D) -> void:
	in_range = false
	
func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "Charging":
		AP.play("Fire")
		get_tree().get_first_node_in_group("camera").start_shaking_that_thang(5.0)
	if anim_name == "Fire":
		AP.play("Cooldown")
	if anim_name == "Cooldown":
		AP.play("Idle")
