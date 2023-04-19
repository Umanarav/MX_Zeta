extends TextureProgressBar

var remainingCooldownTime : float

func _ready():
	# Set the progress bar style.
	max_value = 1000
	value = 0

func _process(delta):
	# Update the progress bar value.
	value = remainingCooldownTime / 1000
