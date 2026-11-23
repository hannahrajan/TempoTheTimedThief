extends Node2D

#================Player SFX================
func play_jump() -> void:
	$SFX/Player/Jump.play()
func play_slide() -> void:
	$SFX/Player/Slide.play()
func play_attack() -> void:
	$SFX/Player/Attack.play()
func play_divekick() -> void:
	$SFX/Player/Divekick.play()
func play_damaged() -> void:
	$SFX/Player/Damaged.play()
#================Enemy SFX================
func play_enemy_damaged() -> void:
	$SFX/Enemy/Damaged.play()
func play_enemy_death() -> void:
	$SFX/Enemy/Death.play()
func play_bombodoro_1() -> void:
	$SFX/Enemy/Bombodoro1.play()
func play_bombodoro_2() -> void:
	$SFX/Enemy/Bombodoro2.play()
#================Treasure SFX================
func play_chest_open() -> void:
	$SFX/Treasure/KeyOpen.play()
func play_treasure_pickup() -> void:
	$SFX/Treasure/Pickup.play()
func play_key_pickup() -> void:
	$SFX/Treasure/PickupKey.play()
func play_key_open() -> void:
	$SFX/Treasure/KeyOpen.play()
#================Miscellaneous SFX================
func play_enter_door() -> void:
	$SFX/Treasure/KeyOpen.play()
func play_enter_portal() -> void:
	$SFX/Enemy/Bombodoro1.play()
func play_break_block() -> void:
	$SFX/Misc/BreakBlock.play()
