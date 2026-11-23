extends Node2D



func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.get("JUMP_PAD_VELOCITY"):
		body.velocity.y = body.JUMP_PAD_VELOCITY
		$AnimationPlayer.play("Activation")
