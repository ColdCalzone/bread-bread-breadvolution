extends Control

# Logo by Symile Silversteen

onready var tween = $Tween
onready var play = $ButtonContainer/Play
onready var settings = $ButtonContainer/Settings
onready var help = $ButtonContainer/Help
onready var quit = $ButtonContainer/Quit
onready var fade = $Fade

onready var title_music = preload("res://Music/Just_Existing_v4.wav")

func play():
	play.disabled = true
	settings.disabled = true
	help.disabled = true
	quit.disabled = true
	tween.interpolate_property(fade, "color", Color(0,0,0,0), Color(0,0,0,1), 0.45, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.start()
	yield(tween, "tween_all_completed")
	get_tree().change_scene("res://scenes/Levels.tscn")

func open_settings():
	play.disabled = true
	settings.disabled = true
	help.disabled = true
	quit.disabled = true
	tween.interpolate_property(fade, "color", Color(0,0,0,0), Color(0,0,0,1), 0.45, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.start()
	yield(tween, "tween_all_completed")
	get_tree().change_scene("res://scenes/Settings.tscn")

func quit():
	play.disabled = true
	settings.disabled = true
	#help.disabled = true
	quit.disabled = true
	tween.interpolate_property(fade, "color", Color(0,0,0,0), Color(0,0,0,1), 0.45, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.start()
	yield(tween, "tween_all_completed")
	get_tree().quit()

# Adding a help button made the UI feel cramped...
func help():
	play.disabled = true
	settings.disabled = true
	help.disabled = true
	quit.disabled = true
	tween.interpolate_property(fade, "color", Color(0,0,0,0), Color(0,0,0,1), 0.45, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.start()
	yield(tween, "tween_all_completed")
	get_tree().change_scene("res://scenes/Help.tscn")

func _ready():
	fade.visible = true
	tween.interpolate_property(fade, "color", Color(0,0,0,1), Color(0,0,0,0), 0.5, Tween.TRANS_LINEAR, Tween.EASE_OUT_IN)
	tween.start()
	play.connect("pressed", self, "play")
	settings.connect("pressed", self, "open_settings")
	#help.connect("pressed", self, "help")
	quit.connect("pressed", self, "quit")
	if not MusicPlayer.stream == title_music:
		MusicPlayer.stream = title_music
		MusicPlayer.play()
