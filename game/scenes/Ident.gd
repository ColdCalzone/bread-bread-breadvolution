extends Control

onready var tween = $Tween
onready var texture = $CenterContainer/TextureRect
onready var label = $CenterContainer/Label
onready var particles = $CenterContainer/Label/CPUParticles2D
onready var audio = $AudioStreamPlayer

var mat

func _ready():
	ScoreTracker.load_config()
	ScoreTracker.load_game()
	OS.center_window()
	
	mat = texture.get_material()
	texture.visible = true
	yield(get_tree().create_timer(2.0), "timeout")
	texture.visible = false
	tween.interpolate_property(label, "modulate:a", 0.0, 1.0, 0.75)
	tween.interpolate_property(particles, "modulate:a", 0.0, 1.0, 0.75)
	tween.start()
	particles.emitting = true
	yield(tween, "tween_all_completed")
	audio.play()
	yield(audio, "finished")
	yield(get_tree().create_timer(0.2), "timeout")
	tween.interpolate_property(label, "modulate:a", 1.0, 0.0, 0.75)
	tween.interpolate_property(particles, "modulate:a", 1.0, 0.0, 0.75)
	tween.start()
	yield(tween, "tween_all_completed")
	get_tree().change_scene("res://scenes/Titlescreen.tscn")

func _input(event):
	if event is InputEventKey:
		get_tree().change_scene("res://scenes/Titlescreen.tscn")

func  _process(delta):
	mat.set_shader_param("time", mat.get_shader_param("time") + delta)
