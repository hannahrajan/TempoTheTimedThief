extends CharacterBody2D

#============================================================================
#==================VARIABLES=================================================
#============================================================================

var speed = 200.0
var direction: float = 0.0

const SLIDESPEED = 500.0		# Sliding movement speed. (Not entirely sure why this has to be set so high to do anything)
const DIVESPEED = 550.0			# Diving movement speed (see above)
const CRAWLSPEED = 120.0		# Crawling movement speed.
const MOVESPEED = 200.0			# Normal movement speed.

const JUMP_VELOCITY = -270.0	# Normal jump velocity.
const JUMP_PAD_VELOCITY = -470.0 # Jump pad velocity.

const ACCEL = 0.15
const FRICTION = 0.2
# This variable changes based on certain zones. Default 1.
# Ex. A slow zone should have this factor set to 0.5.
var SPEEDFACTOR = 1
#like the ohter thing, but for time powers
var timeboost = 1

var is_crouching: bool = false  # Checks if the player is crouching.
var is_damaged: bool = false	# Checks if the player is damaged.
var is_sliding: bool = false    # Checks if the player is sliding.
var is_transitioning: bool = false # Checks if the player is transitioning.
var can_interact: bool = false	# Checks if the player can interact.
var can_move: bool = true       # Checks if the player can move.

var is_attacking: bool = false	# Checks if the player is attacking.
var is_basic_attacking: bool = false # Checks if attack is the basic attack.
var is_aerial_attacking: bool = false
var is_divekicking: bool = false # Checks if the player is divekicking.

@onready var sprite: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var player_cam: Camera2D = $Camera2D
#================HITFLASH SHADER================
# AnimationPlayer for a shader that indicates a flash of color when
# Tempo takes damage.
@onready var hitflash_player: AnimationPlayer = $HitflashPlayer
#================COYOTE TIME================
@onready var coyote_timer: Timer = $Timers/CoyoteTimer
# Variable that checks if coyote time is relevant and available.
var coyote_time_active: bool = false
#================WALL JUMP================
@onready var walljump_raycast: RayCast2D = $WallJumpRayCast
var walljump_force: float = 500
#================UNCROUCH CHECK================
@onready var uncrouchcheck_raycast: RayCast2D = $UncrouchCheckRayCast
#================COLLISION BOXES================
@onready var collisionbox: CollisionShape2D = $PlayerCollisionBox
@onready var crouchcollisionbox: CollisionShape2D = $CrouchCollisionBox
#================HITBOXES & HURTBOXES================
@onready var hitbox: CollisionShape2D = $Attack/AttackHitbox
@onready var hurtbox: CollisionShape2D = $Hurtbox/PlayerHurtbox
#================VISUAL EFFECTS================
@onready var fx_move: AnimatedSprite2D = $VisualEffects/FX_Move
@onready var fx_slow: AnimatedSprite2D = $VisualEffects/FX_Slow
@onready var fx_wallslide: AnimatedSprite2D = $VisualEffects/FX_WallSlide

@onready var level_timer = get_tree().get_first_node_in_group("level_timer")
#================PRELOADS================
var fx_dki = preload("res://assets/scenes/miscellaneous/effects/fx_divekick_impact.tscn")
var fx_pde = preload("res://assets/scenes/miscellaneous/effects/fx_bounce_gem_burst.tscn")
#============================================================================
#==================FUNCTIONS=================================================
#============================================================================

#================READY================
func _ready():
	add_to_group("player")
	
	# This helps detect when a player animation finishes.
	animation_player.animation_finished.connect(_on_animation_player_animation_finished)
	
	# List of visual effects.
	# Certain criteria may change these to true
	# (ex. slow zone sets fx_slow to true upon entering,
	# then back to false upon exiting)
	fx_move.visible = false
	fx_slow.visible = false
	fx_wallslide.visible = false
	
	
#================PHYSICS PROCESS================
func _physics_process(delta: float) -> void:
	if not can_move:
		animation_player.play("Idle")
		fx_move.visible = false
		return
	
#================GRAVITY================
	if not is_on_floor():
		is_crouching = false				
		velocity += get_gravity() * delta

#================WALL SLIDE================
		if is_on_wall_only() and direction != 0:
			# tweak wall slide speed
			velocity.y = clamp(velocity.y, -99999, 80)
			
			fx_wallslide.play()
			fx_wallslide.visible = true
	
	# Stop wallslide VFX when player leaves wall cling.
	if not is_on_wall_only():
		fx_wallslide.stop()
		fx_wallslide.visible = false

#================CROUCH================
	# The player can only crouch while grounded.
	if Input.is_action_just_pressed("crouch"):
		if is_on_floor():
			is_crouching = true
	if (
		# to make sliding slower or more committal you
		# could make it so you dont stand up until you reach
		# close to crawlspeed (minor buffers are because of lerp btw)
		not Input.is_action_pressed("crouch")
		and is_on_floor()
		and not uncrouchcheck_raycast.is_colliding()
		and abs(velocity.x) < MOVESPEED
		):
		is_crouching = false
	if is_crouching:
		speed = CRAWLSPEED * SPEEDFACTOR * timeboost
		collisionbox.disabled = true
		crouchcollisionbox.disabled = false	
	else:
		speed = MOVESPEED * SPEEDFACTOR * timeboost
		collisionbox.disabled = false
		crouchcollisionbox.disabled = true
		
#================JUMP================
	# If the player is attempting to jump, and they are
	# either grounded or the coyote time window is still active,
	# perform a jump.
	if (
		Input.is_action_just_pressed("jump")
		and not is_crouching
		and (!coyote_timer.is_stopped() or is_on_floor())
		):
		velocity.y = JUMP_VELOCITY
		coyote_timer.stop()
		coyote_time_active = true
		AudioManager.play_jump()
	#================SLIDE================
	if Input.is_action_just_pressed("jump") and is_crouching:
		if direction and abs(velocity.x) < CRAWLSPEED + 5.0:
			velocity.x = SLIDESPEED * direction
			animation_player.play("Slide")
			AudioManager.play_slide()
		
#================FALL================
	# Allows the player to perform short hops.
	if (
		Input.is_action_just_released("jump") and velocity.y < 0
		):
		velocity.y = JUMP_VELOCITY / 4
	
#================WALL JUMP================
# Only trigger when an x-direction is being held.
	if (
		is_on_wall_only()
		and direction != 0
		and Input.is_action_just_pressed("jump")
		):
		# When raycast scale is -1/1, player is facing left/right.
		# So wall jump should provide a boost in the opposite direction.
		velocity.y = JUMP_VELOCITY
		velocity.x = -(walljump_raycast.scale.x) * walljump_force
		AudioManager.play_jump()
	
#================COYOTE TIME================
# If the player is grounded and the coyote time window is active,
# deactivate the coyote time window.
	if is_on_floor():
		if coyote_time_active:
			coyote_time_active = false
			coyote_timer.stop()
	else:
		if not coyote_time_active:
			coyote_time_active = true
			coyote_timer.start()

#================BASIC ATTACK================
# A basic attack.
	if (
		Input.is_action_just_pressed("attack")
		and not is_attacking
		and not is_crouching
		and is_on_floor()
		and $Timers/BasicAttackCooldown.time_left <= 0
		):
		is_attacking = true
		animation_player.play("Attack")
		AudioManager.play_attack()
		
#================DIVE KICK================
	if (
		Input.is_action_just_pressed("attack") 
		and not is_on_floor() 
		):
		if (
			Input.is_action_pressed("crouch")
		):
			#is_divekicking = true
			velocity.x = DIVESPEED * sign(hitbox.position.x)
			velocity.y = 300
					
			AudioManager.play_divekick()
		else:
			is_attacking = true
			is_aerial_attacking = true
			animation_player.play("Air Attack")
			AudioManager.play_attack()
			$Timers/HurtCooldown.start(0.1)
		
	# This line prevents the attack animation from being
	# interrupted by anything else.
	if is_attacking and not is_aerial_attacking:
		return
	
	#================DIVE KICK================
	if (Input.is_action_just_pressed("timepower1") and not is_attacking
		and not is_crouching):
			level_timer.remove_time(5)
			timeboost = 1.8
			hitflash_player.play("Time Flash")
			$Timers/HurtCooldown.start(3)
			get_tree().create_timer(3.0).timeout.connect(func(): timeboost = 1.0)
			
	
	
	
	
#================MOVE================
# Input direction.
	direction = Input.get_axis("move_left", "move_right")
	
	# Handle the movement/deceleration.
	if direction:
		velocity.x = lerp(velocity.x, direction * speed, ACCEL)
	else:
		velocity.x = lerp(velocity.x, 0.0, FRICTION)
	
#================ANIMATIONS================
	# If the player is grounded:
	if is_on_floor() and not is_attacking:
		# If the player is crouching:
		if is_crouching:
			fx_move.visible = false
			# If the player is moving while crouching:
			if direction:
				if animation_player.current_animation == "Slide":
					animation_player.play("Slide")
				
				if abs(velocity.x) < CRAWLSPEED + 10.0:
					animation_player.play("Crawl")
				if animation_player.current_animation == "Slide":
					animation_player.play("Slide")
				else:
					animation_player.play("Crawl")
			else:
				animation_player.play("CrouchBeta")
		# If the player is not crouching:
		else:
			# If the player is moving:
			if direction:
				animation_player.play("Move")
				fx_move.visible = true
			else:
				animation_player.play("Idle")
				fx_move.visible = false
	
	#=================================================
	# Moved physics before animation to fix small visual jank
	move_and_slide()
	sprite_flip()
				
	# If the player is airborne:
	if not is_on_floor() and not is_aerial_attacking:
		fx_move.visible = false
		# if animation is flip animation keep doing that
		if animation_player.current_animation == "Flip":
			pass
		# if player is moving fast enough to be diving
		elif velocity.y > 0:
			if abs(velocity.x) / timeboost > MOVESPEED + 20:
				animation_player.play("DiveKick")
			#else:
				#animation_player.play("DiveKick Straight")
		# If the player is moving upward:
		elif sign(velocity.y) == -1:
			animation_player.play("Jump")
		# If the player is moving downward:
		else:
			animation_player.play("FallBeta")
			
	if is_on_wall_only() and velocity.y > 0 and direction != 0:
		animation_player.play("WallSlide")
	
	# Disable hitboxes once animations are finished/interrupted.
	if animation_player.current_animation != "DiveKick":
		$DiveKick/DiveHitbox.disabled = true
	if animation_player.current_animation != "Air Attack":
		$Attack/AttackHitbox.disabled = true

#================PROCESS================
func _process(delta: float) -> void:
	# When the invulnerability period after taking damage has finished
	# (ex. the timer for it is up), restore hurtbox.
	if $Timers/HurtCooldown.time_left > 0:
		hurtbox.disabled = true
	else:
		hurtbox.disabled = false
		
	#if Input.is_action_just_pressed("timepower1"):
		#Engine.time_scale = 0.5
	#if Input.is_action_just_pressed("timepower2"):
		#Engine.time_scale = 1

#================SPRITE FLIP================
# Logic to reverse sprites, some VFX and hitboxes based on x direction.
# Tempo's sprites face right by default.
func sprite_flip():
	if direction > 0:
		sprite.flip_h = false
		fx_move.flip_h = false
		fx_wallslide.flip_h = false
		if sign(hitbox.position.x) == -1:
			hitbox.position.x *= -1
		if sign($DiveKick/DiveHitbox.position.x) == -1:
			$DiveKick/DiveHitbox.position.x *= -1
		if sign(walljump_raycast.scale.x) == -1:
			walljump_raycast.scale.x *= -1
	elif direction < 0:
		sprite.flip_h = true
		fx_move.flip_h = true
		fx_wallslide.flip_h = true
		if sign(hitbox.position.x) == 1:
			hitbox.position.x *= -1
		if sign($DiveKick/DiveHitbox.position.x) == 1:
			$DiveKick/DiveHitbox.position.x *= -1
		if sign(walljump_raycast.scale.x) == 1:
			walljump_raycast.scale.x *= -1
		
#================FINISH ANIMATION================
# After finishing an attack animation, return normal controls.
func _on_animation_player_animation_finished(animation: StringName) -> void:
	if animation == "Attack" or "Air Attack" or "DiveKick":
		is_attacking = false
		is_aerial_attacking = false
		
		# When the basic attack cooldown timer is up,
		# the player can perform a basic attack again.
		if animation == "Attack":
			$Timers/BasicAttackCooldown.start()

#================SLOW ZONE================
# Upon entering a slow zone hazard, Tempo's movement speeed should be
# decreased. Upon exiting, return to normal.
func enter_slow_zone() -> void:
	SPEEDFACTOR = 0.35
	fx_slow.visible = true
func exit_slow_zone() -> void:	
	SPEEDFACTOR = 1
	fx_slow.visible = false

#================DIVE BOUNCE================
# Upon dive-kicking something, Tempo may bounce off of it.
# An impact VFX is instantiated at the spot of collision for flair.
func dive_bounce():
	var impact = fx_dki.instantiate()
	impact.global_position = position	
	get_parent().call_deferred("add_child", impact)
	impact.play()
	velocity.y = -300
	$Timers/HurtCooldown.start(1)
	$AnimationPlayer.play("Flip")

#================DAMAGE COLLISION================
# When an enemy/hazard attack hitbox enters Tempo's hurtbox,
# Tempo's timer loses seconds,
# and he gets knocked back a bit.
func _on_hurtbox_area_entered(area: Area2D) -> void:
	if area is damageArea:
		# Wait until the end of the frame before applying the hit.
		# If a dive kick lands on the same enemy this frame, dive_bounce()
		# will have started the invincibility timer by then.
		check_hit.call_deferred(area)

func check_hit(area: Area2D) -> void:
	# Check the timer directly, since hurtbox.disabled
	# only updates in _process() and can be a frame behind.
	if is_instance_valid(area) and $Timers/HurtCooldown.is_stopped():
		take_damage(area.damage, area.global_position, area.knock_force)
	
func take_damage(amount: int, hazard_pos: Vector2, knockback: float) -> void:
	# Subtract from timer.
	var time = level_timer.leveltimer.time_left
	time -= amount
	
	# Tempo dies if the timer hits 0.
	if time <= 0:
		level_timer.leveltimer.stop()
		die()
	# Otherwise, knock Tempo back and start a timer.
	# Tempo will have invincibility frames that disable his hurtbox.
	# Then, when the timer is finished, restore Tempo's hurtbox.
	else:
		level_timer.leveltimer.start(time)
		
		var knock_dir: Vector2 = (global_position - hazard_pos).normalized()
		velocity = knock_dir * knockback
		
		hitflash_player.play("Hit Flash")
		AudioManager.play_damaged()
		$Timers/HurtCooldown.start(2)
		
#================DEATH================
func die() -> void:
	# Prevent player from moving during death animation.
	set_physics_process(false)
	can_move = false
	animation_player.play("Death")
	
	await animation_player.animation_finished
	
	# "Kill" player by hiding visibility and disabling hurtbox.
	visible = false
	hurtbox.disabled = true
	
	# Spawn player death explosion effect.
	var pde = fx_pde.instantiate()
	pde.global_position = position	
	get_parent().call_deferred("add_child", pde)
	pde.play()
	
	# Play death sound effect.
