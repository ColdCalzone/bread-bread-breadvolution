extends Control

onready var back = $Back
onready var descent = $CenterContainer/Levels/Descent/Descent
onready var going_up = $CenterContainer/Levels/GoingUp/Descent2
onready var loadout = $CenterContainer/Levels/Loadout/Descent2
onready var descent_score = $CenterContainer/Levels/Descent/Stats/Score
onready var going_up_score = $CenterContainer/Levels/GoingUp/Stats/Score
onready var loadout_score = $CenterContainer/Levels/Loadout/Stats/Score
onready var fade = $Fade
onready var tween = $Tween
onready var cheat_menu = $CheatMenu
onready var levels = $CenterContainer/Levels
onready var cheat_hint = $CheatHint

var k_code_buffer : Array = [[]]
var cheats_activated : bool = ScoreTracker.cheats_enabled

func _input(event):
	if !cheats_activated:
		if event.is_action_pressed("k_code_up"):
			k_code_buffer[0].append("Up")
		elif event.is_action_pressed("k_code_down"):
			k_code_buffer[0].append("Down")
		elif event.is_action_pressed("k_code_left"):
			k_code_buffer[0].append("Left")
		elif event.is_action_pressed("k_code_right"):
			k_code_buffer[0].append("Right")
		elif event.is_action_pressed("k_code_B"):
			k_code_buffer[0].append("B")
		elif event.is_action_pressed("k_code_A"):
			k_code_buffer[0].append("A")
		elif event.is_action_pressed("k_code_start"):
			if ["Up", "Up", "Down", "Down", "Left", "Right", "Left", "Right", "B", "A"] in k_code_buffer:
				cheats_activated = true
				ScoreTracker.enable_cheats()
				cheat_menu.rect_position.x += 103
				cheat_hint.rect_position.y += 19

func play(level : String):
	if SongData.set_level(level):
		tween.interpolate_property(fade, "color", Color(0, 0, 0, 0), Color(0, 0, 0, 1), 0.5, Tween.TRANS_LINEAR)
		tween.interpolate_property(MusicPlayer, "volume_db", 0, -20, 0.5, Tween.TRANS_LINEAR)
		tween.start()
		yield(tween, "tween_all_completed")
		get_tree().change_scene("res://scenes/Game.tscn")

func back():
	tween.interpolate_property(fade, "color", Color(0, 0, 0, 0), Color(0, 0, 0, 1), 0.5, Tween.TRANS_LINEAR)
	tween.start()
	yield(tween, "tween_all_completed")
	get_tree().change_scene("res://scenes/Titlescreen.tscn")

func _ready():
	for level in levels.get_children():
		level.get_node("Stats/Other/LowVis").visible = ScoreTracker.get_completion(level.name)["Low Vis"]
		level.get_node("Stats/Other/Beaten").visible = ScoreTracker.get_completion(level.name)["Beaten"]
		level.get_node("Stats/NoMisses/NoMiss").visible = ScoreTracker.get_completion(level.name)["Sudden Death"]
		level.get_node("Stats/NoMisses/Perfect").visible = ScoreTracker.get_completion(level.name)["Perfect"]
	fade.visible = true
	if ScoreTracker.cheats_enabled:
		cheat_menu.rect_position.x += 103
	if ScoreTracker.any_level_complete() and not ScoreTracker.cheats_enabled:
		tween.interpolate_property(cheat_hint, "rect_position", cheat_hint.rect_position, cheat_hint.rect_position - Vector2(0, 19), 2.0, Tween.TRANS_LINEAR, Tween.EASE_IN, 1.0)
	tween.interpolate_property(fade, "color", Color(0, 0, 0, 1), Color(0, 0, 0, 0), 0.5, Tween.TRANS_LINEAR)
	tween.start()
	descent.connect("pressed", self, "play", ["Descent"])
	going_up.connect("pressed", self, "play", ["Going Up"])
	loadout.connect("pressed", self, "play", ["Loadout"])
	back.connect("pressed", self, "back")
	descent_score.text = "Highscore: " + String(ScoreTracker.get_score("Descent"))
	going_up_score.text = "Highscore: " + String(ScoreTracker.get_score("Going Up"))
	loadout_score.text = "Highscore: " + String(ScoreTracker.get_score("Loadout"))
	
