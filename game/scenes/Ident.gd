extends Node2D

# lmaooo
onready var tween = $Tween
onready var sprite = $lol

func _ready():
	ScoreTracker.load_config()
	ScoreTracker.load_game()
	OS.center_window()
	yield(get_tree().create_timer(0.75), "timeout")
	tween.interpolate_property(sprite, "scale", Vector2(0, 1.045), Vector2(1.4, 1.045), 3.0, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.interpolate_property(sprite, "modulate", Color(1,1,1,1), Color(1,1,1,0), 2.0, Tween.TRANS_LINEAR, Tween.EASE_IN, 1.0)
	tween.start()
	yield(tween, "tween_all_completed")
	yield(get_tree().create_timer(1.0), "timeout")
	get_tree().change_scene("res://scenes/Titlescreen.tscn")
