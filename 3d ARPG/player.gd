extends CharacterBody3D

#ui
var ui

#RayCasts
var attackCast
var blade1Cast
var blade2Cast
var blade3Cast
var blade4Cast
var blade5Cast

#abilities
var ability1Activated = false

#ability1Animation
var player_ability_1_animation_player
var player_ability_1_cooldown_animation_player

#timers
@onready var ability1Timer = get_node("BeyBlade/Ability1Timer")

#attack anim
var swordAnimator
var swordAnim
#when player is hit
var hitAnimator
var hitAnim 

#cooldowns
var cooldownDisplayAnimator
var cooldownDisplay
var ability1CooldownDisplayAnimator
var ability1CooldownDisplay
var ability1SecondsRemainingLabel

#jump anim
var jumpAnimator
var jumpAnim
var jump3Anim

#walk anim
var walkAnimator
var walkAnim
var idleAnimator
var idleAnim

#stats
var curHp : int = 10
var maxHp : int = 10
var damage : int = 1
var gold : int = 0
var McGuffins: int = 4
var attackRate : float = 1
var ability1Rate : float = 5
var lastAttackTime : int = 0
var lastAbility1Time : int = 0
#physics
var moveSpeed : float = 8.0
var jumpForce : float = 10.0
var gravity : float = 15.0

#components
func _ready ():
	var camera = get_node("CameraOrbit")
	
	#WeaponHolder
	attackCast = get_node("AttackRayCast")
	swordAnimator = get_node("./WeaponHolder/SwordAnimator")
	swordAnim = swordAnimator.get_animation("Attack")
	
	#cooldownAnimation
	cooldownDisplayAnimator = get_node("./CanvasLayer/UI/Animation/CooldownDisplayAnimator")
	cooldownDisplay = cooldownDisplayAnimator.get_animation("cooldownTimer")
	ability1SecondsRemainingLabel = get_node("./CanvasLayer/UI/Ability1Cooldown/Ability1SecondsRemainingLabel")
	#beyblade
	blade1Cast = get_node("BeyBlade/BeyBladeAttackRays/Blade1RayCast")
	blade2Cast = get_node("BeyBlade/BeyBladeAttackRays/Blade2RayCast")
	blade3Cast = get_node("BeyBlade/BeyBladeAttackRays/Blade3RayCast")
	blade4Cast = get_node("BeyBlade/BeyBladeAttackRays/Blade4RayCast")
	blade5Cast = get_node("BeyBlade/BeyBladeAttackRays/Blade5RayCast")
	#ability 1 Animation
	player_ability_1_animation_player = get_node("BeyBlade/BeyBladeAnimationPlayer")
	player_ability_1_cooldown_animation_player = get_node("./CanvasLayer/UI/Ability1Cooldown/Ability1CooldownDisplayAnimator")
	player_ability_1_cooldown_animation_player.speed_scale = 1 / ability1Rate
	ability1Timer.start()
	
	jumpAnimator = get_node("./Body/PCJumpAnimationPlayer")
	jumpAnim = jumpAnimator.get_animation("jump")
	jump3Anim = jumpAnimator.get_animation("jump_3")
	
	walkAnimator = get_node("./Body/PCAnimationPlayer")
	walkAnim = walkAnimator.get_animation("walk_cycle")
	
	idleAnimator = get_node("./Body/PCIdleAnimationPlayer")
	idleAnim = idleAnimator.get_animation("idle")
	
	hitAnimator = get_node("./Body/PCHitAnimationPlayer")
	hitAnim = hitAnimator.get_animation("hit")
	
	# initialize the UI
	ui = get_node("CanvasLayer/UI")
	ui.update_health_bar(curHp, maxHp)
	ui.update_gold_text(gold)
	player_ability_1_cooldown_animation_player.play("ability1CooldownTimerAnimation")

#called every physics step (60 times a second)
func _physics_process (delta):
	var input = Vector3()
	# movement inputs
	if Input.is_action_pressed("move_forward"):
		input.z += 1
	if Input.is_action_pressed("move_backward"):
		input.z -= 1
	if Input.is_action_pressed("move_left"):
		input.x += 1
	if Input.is_action_pressed("move_right"):
		input.x -= 1
	# If the player is moving, then play the animation
	if Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right") or Input.is_action_pressed("move_forward") or Input.is_action_pressed("move_backward"):
		if Input.is_action_pressed("move_backward"):
			walkAnimator.play_backwards("walk_cycle")
		else:
			walkAnimator.play("walk_cycle")
		idleAnimator.pause()
	else:
		walkAnimator.pause()
		idleAnimator.play("idle")

	# normalize the input vector to prevent increased diagonal speed
	input = input.normalized()
	# get the relative direction
	var dir = (transform.basis.z * input.z + transform.basis.x * input.x)
	# apply the direction to our velocity
	velocity.x = dir.x * moveSpeed
	velocity.z = dir.z * moveSpeed
	# gravity
	velocity.y -= gravity * delta
	# jump input
	if Input.is_action_pressed("jump") and is_on_floor():
		velocity.y = jumpForce
		var random = randf()
		if random < 0.33:
			jumpAnimator.play("jump")
		elif random < 0.66:
			jumpAnimator.play("jump_4")
		else:
			jumpAnimator.play("jump_3")
	# move along the current velocity
	move_and_slide()
	
	# Get the player's position.
	var player_position = global_transform.origin
	# Check if the player is below a certain height.
	if player_position.y < -144:
		die()
		# Reset the player's position to (0, 0, 0).
		#global_transform.origin = Vector3(0, 0, 0)
		
	if ability1Activated == true:
		if blade1Cast.is_colliding():
			if blade1Cast.get_collider().has_method("take_damage"):
				blade1Cast.get_collider().take_damage(damage)
				print('enemyBeyBladed 1')
		if blade2Cast.is_colliding():
			if blade2Cast.get_collider().has_method("take_damage"):
				blade2Cast.get_collider().take_damage(damage)
				print('enemyBeyBladed 2')
		if blade3Cast.is_colliding():
			if blade3Cast.get_collider().has_method("take_damage"):
				blade3Cast.get_collider().take_damage(damage)
				print('enemyBeyBladed 3')
		if blade4Cast.is_colliding():
			if blade4Cast.get_collider().has_method("take_damage"):
				blade4Cast.get_collider().take_damage(damage)
				print('enemyBeyBladed 4')
		if blade5Cast.is_colliding():
			if blade5Cast.get_collider().has_method("take_damage"):
				blade5Cast.get_collider().take_damage(damage)
				print('enemyBeyBladed 5')				

func _process (delta):
	# attack input
	if Input.is_action_pressed("attack") && ability1Activated != true:
		try_attack()
	if Input.is_action_pressed("ability_1"):
		try_ability_1 ()
	ability1SecondsRemainingLabel.text = str(round(ability1Timer.get_time_left()))
	if ability1SecondsRemainingLabel.text == "0":
		ability1SecondsRemainingLabel.text = ""

# called when we press the attack button
func try_attack ():
	if Time.get_ticks_msec() - lastAttackTime < attackRate * 1000:
		return
	# set the last attack time to now
	lastAttackTime = Time.get_ticks_msec()
	# play the animation
	swordAnimator.stop()
	swordAnimator.play("Attack")
	cooldownDisplayAnimator.stop()
	cooldownDisplayAnimator.play("cooldownTimer")
	# is the ray cast colliding with an enemy?
	if attackCast.is_colliding():
		if attackCast.get_collider().has_method("take_damage"):
			attackCast.get_collider().take_damage(damage)
			print('enemyCollided')

# called when we press the ability 1 button
func try_ability_1 ():
	if Time.get_ticks_msec() - lastAbility1Time < ability1Rate * 1000:
		
		return
	# set the last attack time to now
	lastAbility1Time = Time.get_ticks_msec()
	ability1Timer.start()
	ability1Activated = true
	player_ability_1_animation_player.play("full_spin")
	player_ability_1_cooldown_animation_player.play("ability1CooldownTimerAnimation")
	player_ability_1_cooldown_animation_player.speed_scale = 1 / ability1Rate
	
	# play the animation
	#swordAnimator.stop()
	#swordAnimator.play("Attack")
	#cooldownDisplayAnimator.stop()
	#cooldownDisplayAnimator.play("cooldownTimer")
	# is the ray cast colliding with an enemy?

# called when we collect a coin
func give_gold (amount):
	gold += amount
	# update the UI
	ui.update_gold_text(gold)
	
# called when we collect a coin
func give_mc_guffin (amount):
	McGuffins += amount
	print(McGuffins)

	
func get_quest ():
	ui.get_quest_title_text_1()
func complete_quest():
	ui.complete_quest_title_text_1()
func update_quest(McGuffins):
	ui.update_quest_title_text_1(McGuffins)

# called when an enemy deals damage to us
func take_damage (damageToTake):
	curHp -= damageToTake
	hitAnimator.play("hit")
	# if our health is 0, die
	if curHp <= 0:
		die()
		# called when our health reaches 0
	# update the UI
	ui.update_health_bar(curHp, maxHp)

func die ():
	# reload the scene
	get_tree().reload_current_scene()

func _on_ability_1_timer_timeout():
	ability1Activated = false
	player_ability_1_animation_player.seek(0)
	player_ability_1_animation_player.stop()
