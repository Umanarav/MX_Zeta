extends Area3D

var player
var ui

var mcGuffinToGive : int = 1
var rotateSpeed : float = 3.4

func _ready ():
	player = get_node("/root/MainScene/Player")
	ui = get_node("/root/MainScene/Player/CanvasLayer/UI")

# called every frame
func _process (delta):
	# rotate along the Y axis
	rotate_y(rotateSpeed * delta)

func _on_body_entered(body):
	# is this the player? If so give them gold
	if body.name == "Player":
		body.give_mc_guffin(mcGuffinToGive)
		ui.update_quest_title_text_1(player.McGuffins)
		queue_free()
