extends Node2D

# Checks for current level.
@onready var current_level: int = 0
# 0 = tutorial
# 1 = clock tower
# 2 = warp temple ruins
# 3 = hoonos galleria
# 100 = hub world
 
func _ready() -> void:
	if get_tree().current_scene.name == "HubWorld":
		current_level = 100
	elif get_tree().current_scene.name == "TutorialTheClockTower":
		current_level = 0
	elif get_tree().current_scene.name == "Level1WarpTempleRuins":
		current_level = 1
	elif get_tree().current_scene.name == "Level2HoonosGalleria":
		current_level = 2
		
