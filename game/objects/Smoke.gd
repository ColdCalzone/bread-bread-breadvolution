extends Sprite

onready var timer = $Timer

var direction_x
var direction_y
var rotation_amount

func _physics_process(delta):
	randomize()
	position.x += delta * direction_x
	position.y -= delta * direction_y
	rotation_degrees += delta * rotation_amount
	self_modulate.a8 -= 1

func dissapate():
	queue_free()

func _ready():
	randomize()
	timer.wait_time = rand_range(3, 5)
	randomize()
	direction_x = rand_range(-20, 20)
	direction_y = rand_range(8, 30)
	randomize()
	rotation_amount = rand_range(-30, 30)
	timer.connect("timeout", self, "dissapate")
	timer.start()
