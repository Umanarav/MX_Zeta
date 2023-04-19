extends CharacterBody3D

#ui
var ui

#attack anim
var attackCast
var swordAnimator
var swordAnim
var cooldownDisplayAnimator
var cooldownDisplay
#when player is hit
var hitAnimator
var hitAnim 

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
var lastAttackTime : int = 0
#physics
var moveSpeed : float = 8.0
var jumpForce : float = 10.0
var gravity : float = 15.0

#components
func _ready ():
	var camera = get_node("CameraOrbit")
	
	attackCast = get_node("AttackRayCast")
	swordAnimator = get_node("./WeaponHolder/SwordAnimator")
	swordAnim = swordAnimator.get_animation("Attack")
	cooldownDisplayAnimator = get_node("./CanvasLayer/UI/Animation/CooldownDisplayAnimator")
	cooldownDisplay = cooldownDisplayAnimator.get_animation("cooldownTimer")
	
	jumpAnimator = get_node("./Body/PCJumpAnimationPlayer")
	jumpAnim = jumpAnimator.get_animation("jump")
	jump3Anim = jumpAnimator.get_animation("jump_3")
	
	walkAnimator = get_node("./Body/PCAnimationPlayer")
	walkAnim = walkAnimator.get_animation("walk_cycle")
	
	idleAnimator = get_node("./Body/PCIdleAnimationPlayer")
	idleAnim = idleAnimator.get_animation("idle")
	
	hitAnimator = get_node("./Body/PCHitAnimationPlayer")
	hitAnim = hitAnimator.get_animation("hit")
	
	ui = get_node("CanvasLayer/UI")
	# initialize the UI
	ui.update_health_bar(curHp, maxHp)
	ui.update_gold_text(gold)

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

func _process (delta):
	# attack input
	if Input.is_action_pressed("attack"):
		try_attack()

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
