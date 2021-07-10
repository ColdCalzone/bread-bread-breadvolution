extends Control

const CONFIG_PATH : String = "user://settings.cfg"

var config : ConfigFile

func _ready():
	config = ConfigFile.new()
	var err = config.load(CONFIG_PATH)
	if err == ERR_FILE_NOT_FOUND:
		err = config.save(CONFIG_PATH)
	if err == OK:
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear2db(config.get_value("sound", "mus_volume", 100)))
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("MUS"), linear2db(config.get_value("sound", "mus_volume", 80)))
	yield(get_tree().create_timer(2.0), "timeout")
	get_tree().change_scene("res://scenes/Ident.tscn")

func _input(event : InputEvent) -> void:
	if event is InputEventKey:
		get_tree().change_scene("res://scenes/Titlescreen.tscn")
