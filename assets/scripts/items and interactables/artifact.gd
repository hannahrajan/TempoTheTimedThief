extends CharacterBody2D
class_name Artifact

@export var artifact_tag: String

var basic_treasure = preload("res://assets/scenes/items and interactables/treasure/basic_treasure.tscn")

func _ready() -> void:
	# If the artifact has already been collected, replace it
	# with a max rarity basic treasure.
	if GameManager.artifacts[artifact_tag] == true:
		var treasure_instance = basic_treasure.instantiate()
		treasure_instance.global_position = position
		get_parent().call_deferred("add_child", treasure_instance)
		treasure_instance.set_rarity(100)
		queue_free()

# Upon the player colliding with the key, increase the player's
# in-level key count accordingly, then remove the key.
func _on_pick_up_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		AudioManager.play_key_pickup()
		GameManager.artifacts[artifact_tag] = true
		queue_free()
