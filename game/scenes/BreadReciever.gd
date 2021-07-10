extends Control

class_name BreadReciever

const SPRITE = preload("res://sprites/bread_outline.png")
const SPRITE_PULSE = preload("res://sprites/bread_pulse.png")

onready var sprite = $Sprite
#onready var game = get_tree().get_root().get_node("Game")

var pressed : bool = false

export(int) var rotation_direction : int = 0

func _ready() -> void:
	sprite.region_rect = Rect2(64 * rotation_direction, 0, 64, 64)

func press() -> void:
	sprite.texture = SPRITE_PULSE
	sprite.scale = Vector2(0.9, 0.9)
	pressed = true

func release() -> void:
	sprite.texture = SPRITE
	sprite.scale = Vector2.ONE
	pressed = false
