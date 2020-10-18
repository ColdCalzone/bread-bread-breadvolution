extends RigidBody2D

onready var sprite = $Sprite

func _ready():
	# Magic.
	randomize()
	apply_central_impulse(Vector2(rand_range(-145, -150), rand_range(-50, -60)))
