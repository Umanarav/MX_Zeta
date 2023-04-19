extends CharacterBody3D

# stats
var curHp : int = 3
var maxHp : int = 3
# attacking
var damage : int = 0
var attackDist : float = 8.5
var attackRate : float = 2.0
# physics
var moveSpeed : float = 0.0
var gravity : float = 15.0
# vectors
var vel : Vector3 = Vector3()
var dir

# components
var player
var ui
var questTitle

#quest 1 vars
var text1
var quest1Accepted = false
var quest1Complete = false

#conversationVars
var conversationOngoing = false

func _ready ():
	player = get_node("/root/MainScene/Player")
	text1 = get_node("Text1")
	ui = get_node("/root/MainScene/Player/CanvasLayer/UI")
	questTitle = get_node("/root/MainScene/Player/CanvasLayer/UI/QuestTitle")

# called 60 times a second
func _physics_process (delta):
	# get the distance from us to the player
	var dist = global_transform.origin.distance_to(player.global_transform.origin)
	dir = (player.global_transform.origin - global_transform.origin).normalized()
	vel.x = dir.x
	vel.y = 0
	vel.z = dir.z
	look_at(global_transform.origin + vel, Vector3.UP)
	
	if dist > attackDist:
		if conversationOngoing == true:
			conversationOngoing = false
			text1.visible = false
	else :
		if conversationOngoing == false:
			conversationOngoing = true
			text1.visible = true
		else:
			if Input.is_action_pressed("interact") && quest1Accepted == true && player.McGuffins >= 5:
					player.complete_quest()
					player.McGuffins -= 5
					quest1Accepted = false
					quest1Complete = true
					questTitle.visible = false
					text1.text = "Thank you...!"
			elif Input.is_action_pressed("interact") && quest1Accepted != true && quest1Complete != true:
				if quest1Accepted == false:
					player.get_quest()
					quest1Accepted = true
					questTitle.visible = true
					ui.update_quest_title_text_1(player.McGuffins)
	if quest1Accepted == true && player.McGuffins < 5:
		text1.text = "Come back when you got 5 McGuffins"
	elif quest1Accepted == true && player.McGuffins >= 5:
		text1.text = "Give me your McGuffins(press F to give)"

