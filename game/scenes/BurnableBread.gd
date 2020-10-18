extends Node2D

onready var sprite = $Sprite
onready var burn_area = $BurnArea
onready var toast1 = $Toasting1
onready var toast2 = $Toasting2
onready var toast3 = $Toasting3
onready var tween = $Tween

const DEFAULT_SPRITE = preload("res://sprites/bread.png")
const TOASTY_SPRITE = preload("res://sprites/bread_toast.png")
const TOASTIER_SPRITE = preload("res://sprites/bread_toastier.png")
const BURNT_SPRITE = preload("res://sprites/bread_burnt.png")
const BURNT_BREAD = preload("res://objects/BurntBread.tscn")

var rotation_speed : float = 150

signal game_over
signal toasting(multiplyer)

func burn_bread():
	set_physics_process(false)
	sprite.texture = BURNT_SPRITE
	var bread = BURNT_BREAD.instance()
	bread.transform = get_global_transform()
	bread.rotation_degrees = sprite.rotation_degrees
	get_tree().get_root().get_node("Game").call_deferred("add_child", bread)
	emit_signal("game_over")
	queue_free()

func pulse_with_beat():
	tween.interpolate_property(sprite, "scale", Vector2(1, 1), Vector2(1.2, 1.2), 0.1, Tween.TRANS_LINEAR)
	tween.interpolate_property(sprite, "scale", Vector2(1.2, 1.2), Vector2(1, 1), 0.1, Tween.TRANS_LINEAR, Tween.EASE_IN, 0.1)
	tween.start()

func toast(multiplyer : int):
	#print(multiplyer)
	emit_signal("toasting", multiplyer)
	match multiplyer:
		1:
			sprite.texture = TOASTY_SPRITE
			rotation_speed = 200
		2:
			sprite.texture = TOASTIER_SPRITE
			rotation_speed = 300
		3:
			rotation_speed = 500
		-3:
			sprite.texture = TOASTIER_SPRITE
			rotation_speed = 300
		-2:
			sprite.texture = TOASTY_SPRITE
			rotation_speed = 200
		-1:
			sprite.texture = DEFAULT_SPRITE
			rotation_speed = 150

func _physics_process(delta):
	sprite.rotation_degrees -= delta * rotation_speed

func _ready():
	connect("game_over", get_tree().get_root().get_node("Game"), "game_over")
	connect("toasting", get_tree().get_root().get_node("Game"), "toasting")
