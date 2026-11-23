extends Control

@onready var treasure_label: Label = $Labels/TreasureLabel
@onready var keys_label: Label = $Labels/KeysLabel

func _ready() -> void:
	if LevelManager.current_level == 100:
		$Artifacts.visible = false
	else:
		$Artifacts.visible = true
	
#==============Change HUD appearance of artifacts.==============
	
	# Change visibility based on level.
	match LevelManager.current_level:
		# Level 0 / Tutorial Level
		0:
			$Artifacts/A1.visible = true
			$Artifacts/A2.visible = true
			$Artifacts/A3.visible = true
			$Artifacts/A4.visible = false
			$Artifacts/A5.visible = false
			$Artifacts/A6.visible = false
			$Artifacts/A7.visible = false
			$Artifacts/A8.visible = false
			
			# Change visibility based on whether or not artifact was collected. 
			if GameManager.artifacts["Lvl 0 Artifact 1"] == false:
				$Artifacts/A1.self_modulate.a = 0.5
				$Artifacts/A1.self_modulate = Color(0.0, 0.0, 0.0, 1.0)
			if GameManager.artifacts["Lvl 0 Artifact 2"] == false:
				$Artifacts/A2.self_modulate.a = 0.5
				$Artifacts/A2.self_modulate = Color(0.0, 0.0, 0.0, 1.0)
			if GameManager.artifacts["Lvl 0 Artifact 3"] == false:
				$Artifacts/A3.self_modulate.a = 0.5
				$Artifacts/A3.self_modulate = Color(0.0, 0.0, 0.0, 1.0)
		# Level 1 / Warp Temple Ruins		
		1:
			$Artifacts/A1.visible = true
			$Artifacts/A2.visible = true
			$Artifacts/A3.visible = true
			$Artifacts/A4.visible = true
			$Artifacts/A5.visible = true
			$Artifacts/A6.visible = false
			$Artifacts/A7.visible = false
			$Artifacts/A8.visible = false
			
			if GameManager.artifacts["Lvl 1 Artifact 1"] == false:
				$Artifacts/A1.self_modulate.a = 0.5
				$Artifacts/A1.self_modulate = Color(0.0, 0.0, 0.0, 1.0)
			if GameManager.artifacts["Lvl 1 Artifact 2"] == false:
				$Artifacts/A2.self_modulate.a = 0.5
				$Artifacts/A2.self_modulate = Color(0.0, 0.0, 0.0, 1.0)
			if GameManager.artifacts["Lvl 1 Artifact 3"] == false:
				$Artifacts/A3.self_modulate.a = 0.5
				$Artifacts/A3.self_modulate = Color(0.0, 0.0, 0.0, 1.0)
			if GameManager.artifacts["Lvl 1 Artifact 4"] == false:
				$Artifacts/A4.self_modulate.a = 0.5
				$Artifacts/A4.self_modulate = Color(0.0, 0.0, 0.0, 1.0)
			if GameManager.artifacts["Lvl 1 Artifact 5"] == false:
				$Artifacts/A5.self_modulate.a = 0.5
				$Artifacts/A5.self_modulate = Color(0.0, 0.0, 0.0, 1.0)

func _process(delta: float) -> void:
	treasure_label.text = str(GameManager.temp_treasure)
	keys_label.text = str(GameManager.temp_keys)

	match LevelManager.current_level:
		# Level 0 / Tutorial Level
		0:
			if GameManager.artifacts["Lvl 0 Artifact 1"] == true:
				$Artifacts/A1.self_modulate.a = 1
				$Artifacts/A1.self_modulate = Color(1.0, 1.0, 1.0, 1.0)
			if GameManager.artifacts["Lvl 0 Artifact 2"] == true:
				$Artifacts/A2.self_modulate.a = 1
				$Artifacts/A2.self_modulate = Color(1.0, 1.0, 1.0, 1.0)
			if GameManager.artifacts["Lvl 0 Artifact 3"] == true:
				$Artifacts/A3.self_modulate.a = 1
				$Artifacts/A3.self_modulate = Color(1.0, 1.0, 1.0, 1.0)
		# Level 1 / Warp Temple Ruins	
		1:
			if GameManager.artifacts["Lvl 1 Artifact 1"] == true:
				$Artifacts/A1.self_modulate.a = 1
				$Artifacts/A1.self_modulate = Color(1.0, 1.0, 1.0, 1.0)
			if GameManager.artifacts["Lvl 1 Artifact 2"] == true:
				$Artifacts/A2.self_modulate.a = 1
				$Artifacts/A2.self_modulate = Color(1.0, 1.0, 1.0, 1.0)
			if GameManager.artifacts["Lvl 1 Artifact 3"] == true:
				$Artifacts/A3.self_modulate.a = 1
				$Artifacts/A3.self_modulate = Color(1.0, 1.0, 1.0, 1.0)
			if GameManager.artifacts["Lvl 1 Artifact 4"] == true:
				$Artifacts/A4.self_modulate.a = 1
				$Artifacts/A4.self_modulate = Color(1.0, 1.0, 1.0, 1.0)
			if GameManager.artifacts["Lvl 1 Artifact 5"] == true:
				$Artifacts/A5.self_modulate.a = 1
				$Artifacts/A5.self_modulate = Color(1.0, 1.0, 1.0, 1.0)
