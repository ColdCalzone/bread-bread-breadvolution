extends Control

onready var back = $ButtonContainer/Quit
onready var fade = $Fade
onready var tween = $Tween

func back():
	tween.interpolate_property(fade, "color", Color(0, 0, 0, 0), Color(0, 0, 0, 1), 0.5, Tween.TRANS_LINEAR)
	tween.start()
	yield(tween, "tween_all_completed")
	get_tree().change_scene("res://scenes/Settings.tscn")

func _ready():
	fade.visible = true
	tween.interpolate_property(fade, "color", Color(0, 0, 0, 1), Color(0, 0, 0, 0), 0.5, Tween.TRANS_LINEAR)
	tween.start()
	back.connect("pressed", self, "back")
