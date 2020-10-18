extends Node2D

class_name Bread

const SPRITE = preload("res://sprites/bread.png")
const TOASTY_SPRITE = preload("res://sprites/bread_toast.png")
const TOASTIER_SPRITE = preload("res://sprites/bread_toastier.png")
const BURNT_SPRITE = preload("res://sprites/bread_burnt.png")

onready var sprite = $Sprite
onready var sweet_sprite = $Sweet
onready var points_label = $Points
onready var tween = $Tween
onready var timer = $Timer
onready var game = get_tree().get_root().get_node("Game")

export(int) var rotation_direction : int = 0
export(int) var speed = 200
var moving : bool = true
var anim_index : int = 0

signal bread_hit
signal burn_bread

func delete(sweet : bool, points : int) -> void:
	points *= (game.multiplyer if game.multiplyer > 0 else 1)
	tween.interpolate_property(sweet_sprite, "position", sweet_sprite.position, Vector2(32, -16), 1.0, Tween.TRANS_LINEAR)
	tween.interpolate_property(points_label, "rect_position", points_label.rect_position, Vector2(24, -64), 1.0, Tween.TRANS_LINEAR)
	game.points += points
	#tween.interpolate_property(get_parent(), "points", get_parent().points, get_parent().points + points * get_parent().multiplyer, 0.0, Tween.TRANS_LINEAR)
	game.consecutive_sweets = max(game.consecutive_sweets, 0)
	if points > 0:
		tween.interpolate_property(game.point_label, "rect_scale", Vector2(1, 1), Vector2(1.1, 1.1), 0.1, Tween.TRANS_LINEAR)
		tween.interpolate_property(game.point_label, "rect_scale", Vector2(1.1, 1.1), Vector2(1, 1), 0.1, Tween.TRANS_LINEAR)
		tween.interpolate_property(game.hit_label, "rect_scale", Vector2(1, 1), Vector2(1.1, 1.1), 0.1, Tween.TRANS_LINEAR)
		tween.interpolate_property(game.hit_label, "rect_scale", Vector2(1.1, 1.1), Vector2(1, 1), 0.1, Tween.TRANS_LINEAR)
		game.consecutive_hits += 1
		emit_signal("bread_hit")
	else:
		tween.interpolate_property(game.hit_label, "rect_scale", Vector2(1, 1), Vector2(0.9, 0.9), 0.1, Tween.TRANS_LINEAR)
		tween.interpolate_property(game.hit_label, "rect_scale", Vector2(0.9, 0.9), Vector2(1, 1), 0.1, Tween.TRANS_LINEAR)
		tween.interpolate_property(game.point_label, "rect_scale", Vector2(1, 1), Vector2(0.9, 0.9), 0.1, Tween.TRANS_LINEAR)
		tween.interpolate_property(game.point_label, "rect_scale", Vector2(0.9, 0.9), Vector2(1, 1), 0.1, Tween.TRANS_LINEAR)
		tween.interpolate_property(game.sweet_label, "rect_scale", Vector2(1, 1), Vector2(0.9, 0.9), 0.1, Tween.TRANS_LINEAR)
		tween.interpolate_property(game.sweet_label, "rect_scale", Vector2(0.9, 0.9), Vector2(1, 1), 0.1, Tween.TRANS_LINEAR)
		game.consecutive_hits = 0
		game.consecutive_sweets = 0
		emit_signal("bread_hit")
	if sweet: 
		tween.interpolate_property(game.sweet_label, "rect_scale", Vector2(1, 1), Vector2(1.1, 1.1), 0.1, Tween.TRANS_LINEAR)
		tween.interpolate_property(game.sweet_label, "rect_scale", Vector2(1.1, 1.1), Vector2(1, 1), 0.1, Tween.TRANS_LINEAR)
		game.consecutive_sweets += 1
		timer.connect("timeout", self, "sweet_loop")
		timer.start()
		#print("SWEET!")
		moving = false
		sprite.visible = false
		sweet_sprite.visible = true
		points_label.visible = true
		points_label.text = String(points)
	else:
		if ScoreTracker.cheats[3]["sub-cheat"]["value"] and ScoreTracker.cheats[3]["value"]:
			emit_signal("burn_bread")
		game.consecutive_sweets -= 1
		moving = false
		sprite.visible = false
		points_label.visible = true
		points_label.text = String(points)
	tween.start()
	#print(get_parent().points)
	yield(tween, "tween_all_completed")
	queue_free()

func _ready() -> void:
	sprite.region_rect = Rect2(64 * rotation_direction, 0, 64, 64)
	connect("burn_bread", game, "burn_bread_on_perfect_miss")
	connect("bread_hit", game, "consecutive_combos")
	match game.toast_multiplyer:
		7:
			sprite.texture = TOASTIER_SPRITE
		4:
			sprite.texture = TOASTIER_SPRITE
		2:
			sprite.texture = TOASTY_SPRITE
		1:
			sprite.texture = SPRITE

func sweet_loop():
	sweet_sprite.region_rect.position.x += 64
	if sweet_sprite.region_rect.position.x >= 256:
		sweet_sprite.region_rect.position.x = 0

func _physics_process(delta) -> void:
	if moving:
		position.y += delta * speed
		
