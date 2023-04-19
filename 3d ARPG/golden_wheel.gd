extends Node3D

func _ready():
	# Retrieve a reference to the AnimationPlayer node
	var outer_wheel_anim_player = get_node("OuterWheel/AnimationPlayer")
	var outer_wheel_1_anim_player = get_node("OuterWheel-1/AnimationPlayer")
	var outer_wheel_2_anim_player = get_node("OuterWheel-2/AnimationPlayer")
	# Play the animation
	outer_wheel_anim_player.play("spin")
	outer_wheel_1_anim_player.play("spin")
	outer_wheel_2_anim_player.play("spin")
	
	# Retrieve references to the AnimationPlayer nodes

	var outer_wheel_3_anim_player = get_node("OuterWheel-3/AnimationPlayer")
	var center_wheel_2_anim_player = get_node("CenterWheel+2/AnimationPlayer")
	var center_wheel_1_anim_player = get_node("CenterWheel+1/AnimationPlayer")
	var center_wheel_anim_player = get_node("CenterWheel/AnimationPlayer")
	# Play animations

	outer_wheel_3_anim_player.play("spin")
	center_wheel_2_anim_player.play("spin")
	center_wheel_1_anim_player.play("spin")
	center_wheel_anim_player.play("spin")

