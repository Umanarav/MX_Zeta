extends Node3D

var SPEED : float = 144.0
var angle = 0
var cameraSnapback = 5

# look stats
var lookSensitivity : float = 13.0
var minLookAngle : float = -21.0
var maxLookAngle : float = 89.0
# vectors
var mouseDelta = Vector2()

#nodes
var player
var camera_orbit

# called when an input is detected
func _input (event):
	# set "mouseDelta" when we move our mouse
	if event is InputEventMouseMotion:
		mouseDelta = event.relative
# called every frame
func _process(delta):
	# get the rotation to apply to the camera and player
	var rot = Vector3(mouseDelta.y, mouseDelta.x, 0) * lookSensitivity * delta
	# player horizontal rotation
	var is_camera_moving = Input.is_action_pressed("ui_look_leftclick")
	if is_camera_moving:
		camera_orbit.rotation_degrees.y -= rot.y
		
		# Rotate the camera around the CameraOrbit node
	else:
		if camera_orbit.rotation_degrees.y > 0:
			camera_orbit.rotation_degrees.y -= cameraSnapback
		elif camera_orbit.rotation_degrees.y < 0:
			camera_orbit.rotation_degrees.y  += cameraSnapback
		player.rotation_degrees.y -= rot.y
	# camera vertical rotation
	rotation_degrees.x += rot.x
	rotation_degrees.x = clamp(rotation_degrees.x, minLookAngle, maxLookAngle)
	# clear the mouse movement vector
	mouseDelta = Vector2()
	
	#gamepad
	angle += SPEED * delta * delta 
	angle = wrapf(angle, 0, 360)
	if Input.is_action_pressed("ui_look_right"):
		player.rotation_degrees.y -= SPEED * delta
	elif Input.is_action_pressed("ui_look_left"):
		player.rotation_degrees.y -= -SPEED * delta
	if Input.is_action_pressed("ui_look_up"):
		rotation_degrees.x -= SPEED * delta
		rotation_degrees.x = clamp(rotation_degrees.x, minLookAngle, maxLookAngle)
	elif Input.is_action_pressed("ui_look_down"):
		rotation_degrees.x -= -SPEED * delta
		rotation_degrees.x = clamp(rotation_degrees.x, minLookAngle, maxLookAngle)
# called when the node is initialized
func _ready ():
	# components
	player = get_parent()
	camera_orbit = player.get_node("CameraOrbit")

	# hide the mouse cursor
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
