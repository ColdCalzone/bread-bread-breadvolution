extends Control

class_name BreadReciever

const SPRITE = preload("res://sprites/bread_outline.png")
const SPRITE_PULSE = preload("res://sprites/bread_pulse.png")

onready var sprite = $Sprite
onready var bread_collision = $BreadArea/CollisionShape
onready var bread_area = $BreadArea
onready var reading_area = $ReadArea
onready var sweet_reader = $SweetReader
onready var sweet_reader_exit = $SweetReaderExit
onready var sweet_area = $SweetSpot
onready var sweet_collision = $SweetSpot/CollisionShape
onready var timer = $Timer
onready var tween = $TweenGrow
onready var game = get_tree().get_root().get_node("Game")
var bread_in_receiver = []
var bread_overlapping = []
var bread_in_sweet_spot = []

export(int) var rotation_direction : int = 0

func _input(event) -> void:
	if timer.is_stopped():
		if event.is_action_pressed("ui_up") and rotation_direction == 0:
			sprite.texture = SPRITE
			pulse(rotation_direction)
		if event.is_action_pressed("ui_right") and rotation_direction == 1:
			sprite.texture = SPRITE
			pulse(rotation_direction)
		if event.is_action_pressed("ui_down") and rotation_direction == 2:
			sprite.texture = SPRITE
			pulse(rotation_direction)
		if event.is_action_pressed("ui_left") and rotation_direction == 3:
			sprite.texture = SPRITE
			pulse(rotation_direction)

func pulse(direction : int) -> void:
	tween.interpolate_property(sprite, "scale", Vector2(0.9, 0.9), Vector2(1.0, 1.0), 0.1, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	bread_collision.set_deferred("disabled", false)
	sweet_collision.set_deferred("disabled", false)
	sprite.texture = SPRITE_PULSE
	remove_overlapping_bread()
	tween.start()
	timer.start()
	yield(timer, "timeout")
	bread_collision.set_deferred("disabled", true)
	sweet_collision.set_deferred("disabled", true)
	sprite.texture = SPRITE

func remove_overlapping_bread():
	if bread_overlapping.size() > 0:
		for bread in bread_overlapping:
			if bread in bread_in_receiver:
				if bread in bread_in_sweet_spot:
					remove_bread_from_array(bread)
					remove_bread_from_overlapping(bread)
					remove_bread_from_sweet_spot(bread)
					bread.get_parent().delete(true, 1000)
				else:
					remove_bread_from_array(bread)
					remove_bread_from_overlapping(bread)
					remove_bread_from_sweet_spot(bread)
					bread.get_parent().delete(false, 100)
	else:
		if game.start_delay.is_stopped():
			game.misses += 0.25
			game.consecutive_hits = 0
			game.consecutive_sweets = 0
			game.points -= 10
		game.consecutive_combos()

func add_bread_to_array(bread : Node) -> void:
	bread_in_receiver.append(bread)

func remove_bread_from_array(bread : Node) -> void:
	if bread in bread_in_receiver:
		bread_in_receiver.remove(bread_in_receiver.find(bread))

func add_bread_to_overlapping(bread : Node) -> void:
	bread_overlapping.append(bread)

func remove_bread_from_overlapping(bread : Node) -> void:
	if bread in bread_overlapping:
		bread_overlapping.remove(bread_overlapping.find(bread))

func add_bread_to_sweet_spot(bread : Node) -> void:
	bread_in_sweet_spot.append(bread)
	# haha aimbot go BRR
	if ScoreTracker.cheats[0]["value"]:
		pulse(rotation_direction)

func remove_bread_from_sweet_spot(bread : Node) -> void:
	if bread in bread_in_sweet_spot:
		bread_in_sweet_spot.remove(bread_in_sweet_spot.find(bread))

func _ready() -> void:
	sprite.region_rect = Rect2(64 * rotation_direction, 0, 64, 64)
	reading_area.connect("area_entered", self, "add_bread_to_overlapping")
	reading_area.connect("area_exited", self, "remove_bread_from_overlapping")
	sweet_reader.connect("area_entered", self, "add_bread_to_sweet_spot")
	sweet_reader_exit.connect("area_exited", self, "remove_bread_from_sweet_spot")
