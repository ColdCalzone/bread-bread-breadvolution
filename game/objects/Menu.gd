extends Control

onready var tween = $Tween
onready var fade = $Fade
onready var fade_over = $Fade2
onready var resume = $ButtonContainer/Buttons/Resume
onready var restart = $ButtonContainer/Buttons/Restart
onready var quit = $ButtonContainer/Buttons/Quit

var can_resume : bool = true

func _input(event):
	if event.is_action_pressed("ui_cancel") and can_resume:
		resume()

func resume():
	for child in get_children():
		if child.name == "Tween": continue
		child.visible = false
	tween.interpolate_property(fade, "color", Color(0,0,0,0.6), Color(0,0,0,0), 0.3, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	for ui_element in get_parent().ui.get_children():
		ui_element.visible = true
		if ui_element.name == "LimitedVisibility" and not ScoreTracker.cheats[2]["value"]: ui_element.visible = false
	tween.start()
	yield(tween, "tween_all_completed")
	get_tree().paused = false
	get_parent().set_process_input(true)
	get_parent().remove_child(self)

func restart():
	MusicPlayer.volume_db = 0
	MusicPlayer.pitch_scale = 1
	MusicPlayer.stop()
	tween.interpolate_property(fade_over, "color", Color(0,0,0,0), Color(0,0,0,1), 0.3, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tween.start()
	yield(tween, "tween_all_completed")
	get_tree().paused = false
	get_tree().change_scene("res://scenes/Game.tscn")

func quit():
	MusicPlayer.volume_db = 0
	MusicPlayer.pitch_scale = 1
	MusicPlayer.stop()
	tween.interpolate_property(fade_over, "color", Color(0,0,0,0), Color(0,0,0,1), 0.3, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.start()
	yield(tween, "tween_all_completed")
	get_tree().paused = false
	get_tree().change_scene("res://scenes/Titlescreen.tscn")

func _ready():
	for ui_element in get_parent().ui.get_children():
		#if ui_element.name == "LimitedVisibility": continue
		ui_element.visible = false
	tween.start()
	set_process_input(true)
	tween.interpolate_property(fade, "color", Color(0,0,0,0), Color(0,0,0,0.6), 0.1, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.start()
	resume.connect("pressed", self, "resume")
	restart.connect("pressed", self, "restart")
	quit.connect("pressed", self, "quit")
	if not can_resume:
		resume.queue_free()
