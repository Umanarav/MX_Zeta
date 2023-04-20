extends CharacterBody3D

# stats
var curHp : int = 3
var maxHp : int = 3
# attacking
var damage : int = 1
var attackDist : float = 1.5
var attackRate : float = 2.0
# physics
var moveSpeed : float = 3.4
var gravity : float = 15.0
# vectors
var vel : Vector3 = Vector3()
var dir
var dist
#timers
@onready var timer = get_node("Timer")
@onready var deathTimer = get_node("DeathTimer")
@onready var respawnTimer = get_node("RespawnTimer")

# components
var player
var main_scene
var is_on_ground = false

var stunned = false
var damaged = false
var dying = false
var knockbackPending = false
var knockbackValue = 0
var stunnedStars

var bodyCollision

var hatEquipped = true
var hatCollision

var enemy_attack_animation_player 
var enemy_hit_animation_player
var enemy_walk_animation_player
var enemy_idle_animation_player
var enemy_death_animation_player
var enemy_respawn_animation_player
var enemy_stunned_animation_player

func _ready ():
	player = get_node("/root/MainScene/Player")
	main_scene = get_node("/root/MainScene")
	
	enemy_attack_animation_player = get_node("Animations/Attack")
	enemy_attack_animation_player.speed_scale = .5
	enemy_hit_animation_player = get_node("Animations/Hit")
	enemy_walk_animation_player = get_node("Animations/Walk")
	
	enemy_death_animation_player = get_node("Animations/Die")
	enemy_respawn_animation_player = get_node("Animations/Respawn")
	enemy_stunned_animation_player = get_node("Animations/Stunned")
	
	hatCollision = get_node("HatCollision")
	bodyCollision = get_node("BodyCollision")
	stunnedStars = get_node("Mesh/HatRing/stunnedStars")
	
	# set the timer wait time
	timer.wait_time = attackRate
	timer.start()

func _on_timer_timeout():
	# if we're within the attack distance - attack the player
	if global_transform.origin.distance_to(player.global_transform.origin) <= attackDist && dying != true:
		if stunned == false:
			player.take_damage(damage)
			enemy_stunned_animation_player.stop()
			enemy_attack_animation_player.stop(true)
			enemy_attack_animation_player.play("Attack")
			


	if stunned == true:
		stunned = false
		stunnedStars.visible = false
		enemy_stunned_animation_player.stop()
		enemy_stunned_animation_player.play("stunrecovery")
		#play idle attack
		print('missed attack because player hit enemy')

# called 60 times a second
func _physics_process (delta):
	# rotate to face the direction of movements
	if dying != true && stunned != true:
		# get the distance from us to the player
		dist = global_transform.origin.distance_to(player.global_transform.origin)
		# calculate the direction between us and the player
		dir = (player.global_transform.origin - global_transform.origin).normalized()	
		vel.x = dir.x
		vel.y = 0
		vel.z = dir.z
		# move towards the player
		# if we're outside of the attack distance, chase after the player
		if dist > attackDist && dying != true:
			enemy_walk_animation_player.play("Walk")
			move_and_collide(vel * delta)
		else :
			enemy_walk_animation_player.stop(true)
		look_at(global_transform.origin + vel, Vector3.UP)
	if knockbackPending == true:
			if knockbackValue > 0:
				knockbackValue -= 1
				move_and_collide((-vel * delta) * knockbackValue)
			else:
				knockbackPending = false

# called when the player deals damage to us
func take_damage (damageToTake):
	enemy_hit_animation_player.stop(true)
	enemy_attack_animation_player.stop(true)
	if knockbackPending == false:
		knockbackPending = true
		knockbackValue = 13
		stunned = true
		stunnedStars.visible = true
		enemy_stunned_animation_player.play('stunned')
	if damaged == true && dying != true && hatEquipped == true:
		enemy_hit_animation_player.play("Hit_2")
		hatEquipped = false
		hatCollision.disabled = true
	elif damaged == false && dying != true:
		enemy_hit_animation_player.play("Hit")
		damaged = true
	
	curHp -= damageToTake
	print('enemy damaged')
	# if our health reaches 0 - die
	if curHp <= 0 && dying != true:
		die()
		# called when our health reaches 0

func die():
	enemy_death_animation_player.play("death")
	bodyCollision.disabled = true
	deathTimer.start()
	dying = true

func _on_death_timer_timeout():
	#main_scene.currentEnemyCount -= 1
	respawnTimer.start()

func _on_respawn_timer_timeout():
	respawn()

func respawn():
	resetEnemyAnimation()
	enemy_respawn_animation_player.play("respawn")
	curHp = maxHp
	bodyCollision.disabled = false
	hatCollision.disabled = false
	damaged = false
	dying = false
	knockbackPending = false
	knockbackValue = 0
	stunned = false
	hatEquipped = true
	global_transform.origin = Vector3(randf_range(-5, 5), 0, randf_range(-5, 5))

func resetEnemyAnimation():
	stunnedStars.visible = false
	enemy_death_animation_player.seek(0)
	enemy_death_animation_player.stop()
	enemy_hit_animation_player.play("Hit_2")
	enemy_hit_animation_player.seek(0)
	enemy_hit_animation_player.stop()
	enemy_hit_animation_player.play("Hit")
	enemy_hit_animation_player.seek(0)
	enemy_hit_animation_player.stop()
