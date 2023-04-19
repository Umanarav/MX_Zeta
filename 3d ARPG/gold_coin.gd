extends Area3D

var goldToGive : int = 1
var rotateSpeed : float = 3.4

# called every frame
func _process (delta):
	# rotate along the Y axis
	rotate_y(rotateSpeed * delta)

func _on_body_entered(body):
	# is this the player? If so give them gold
	if body.name == "Player":
		body.give_gold(goldToGive)
		queue_free()
