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
#timers
@onready var timer = get_node("Timer")
@onready var deathTimer = get_node("DeathTimer")
# components
var player
var is_on_ground = false

var damaged = false
var dying = false

var bodyCollision

var hatEquipped = true
var hatCollision

var enemy_attack_animation_player 
var enemy_hit_animation_player
var enemy_walk_animation_player
var enemy_idle_animation_player
var enemy_death_animation_player

func _ready ():
	player = get_node("/root/MainScene/Player")
	enemy_attack_animation_player = get_node("Animations/Attack")
	enemy_attack_animation_player.speed_scale = .5
	enemy_hit_animation_player = get_node("Animations/Hit")
	enemy_walk_animation_player = get_node("Animations/Walk")
	enemy_death_animation_player = get_node("Animations/Die")
	hatCollision = get_node("HatCollision")
	bodyCollision = get_node("BodyCollision")
	
	# set the timer wait time
	timer.wait_time = attackRate
	timer.start()

func _on_timer_timeout():
	# if we're within the attack distance - attack the player
	if global_transform.origin.distance_to(player.global_transform.origin) <= attackDist && dying != true && damaged == false:
		player.take_damage(damage)
		enemy_attack_animation_player.stop(true)
		enemy_attack_animation_player.play("Attack")
	if damaged == true:
		damaged = false
		print('missed attack because player hit enemy')

# called 60 times a second
func _physics_process (delta):
	if dying != true:
		# get the distance from us to the player
		var dist = global_transform.origin.distance_to(player.global_transform.origin)
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
			# rotate to face the direction of movement
		look_at(global_transform.origin + vel, Vector3.UP)

# called when the player deals damage to us
func take_damage (damageToTake):
	enemy_hit_animation_player.stop(true)
	enemy_attack_animation_player.stop(true)
	
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
	# Destroy the node
	queue_free()
