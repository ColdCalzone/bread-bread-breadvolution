extends Control

onready var volume = $Sound/HBox/VBox/HSlider
onready var fullscreen = $Other/HBox/VBox/CheckButton
# TODO Change texture
onready var fade = $Fade
onready var tween = $Tween
onready var back = $Back/Back
onready var credits = $Credits/Credits

const CONFIG_PATH : String = "user://settings.cfg"

var config : ConfigFile

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		back()

func back():
	tween.interpolate_property(fade, "color", Color(0, 0, 0, 0), Color(0, 0, 0, 1), 0.5, Tween.TRANS_LINEAR)
	tween.start()
	yield(tween, "tween_all_completed")
	get_tree().change_scene("res://scenes/Titlescreen.tscn")

func credits():
	tween.interpolate_property(fade, "color", Color(0, 0, 0, 0), Color(0, 0, 0, 1), 0.5, Tween.TRANS_LINEAR)
	tween.start()
	yield(tween, "tween_all_completed")
	get_tree().change_scene("res://scenes/Credits.tscn")

func toggle_fullscreen(pressed):
	OS.set_window_fullscreen(pressed)
	save_config()

func change_volume(current_volume):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear2db(current_volume))
	save_config()

func load_config():
	config = ConfigFile.new()
	var err = config.load(CONFIG_PATH)
	if err == ERR_FILE_NOT_FOUND:
		err = config.save(CONFIG_PATH)
	if err == OK:
		volume.value = config.get_value("sound", "music_volume", 1)
		fullscreen.pressed = config.get_value("graphics", "fullscreen", false)
		ScoreTracker.cheats_enabled = config.get_value("game", "cheats_enabled", false)

func enable_cheats():
	config.set_value("game", "cheats_enabled", true)
	ScoreTracker.cheats_enabled = config.get_value("game", "cheats_enabled", false)

func save_config():
	config.set_value("sound", "music_volume", volume.value)
	config.set_value("graphics", "fullscreen", fullscreen.pressed)
	config.save(CONFIG_PATH)

func _ready():
	load_config()
	fade.visible = true
	tween.interpolate_property(fade, "color", Color(0, 0, 0, 1), Color(0, 0, 0, 0), 0.5, Tween.TRANS_LINEAR)
	tween.start()
	back.connect("pressed", self, "back")
	fullscreen.connect("toggled", self, "toggle_fullscreen")
	volume.connect("value_changed", self, "change_volume")
	credits.connect("pressed", self, "credits")
