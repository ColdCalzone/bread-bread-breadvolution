extends Node2D

const SMOKE = preload("res://objects/Smoke.tscn")
const MENU = preload("res://objects/Menu.tscn")

var raw_song_data = SongData.current_level
var song_data

onready var spawner_container = $CenterSpawner/SpawnerContainer
onready var deletion_zone = $DeletionZone

onready var oven1 = $CenterSpawner/SpawnerContainer/Oven
onready var oven2 = $CenterSpawner/SpawnerContainer/Oven2
onready var oven3 = $CenterSpawner/SpawnerContainer/Oven3
onready var oven4 = $CenterSpawner/SpawnerContainer/Oven4
onready var receiver1 = $CenterReciever/RecieverContainer/BreadReciever
onready var receiver2 = $CenterReciever/RecieverContainer/BreadReciever2
onready var receiver3 = $CenterReciever/RecieverContainer/BreadReciever3
onready var receiver4 = $CenterReciever/RecieverContainer/BreadReciever4

onready var point_label = $UI/Points
onready var hit_label = $UI/HitCombo
onready var combo_total = $UI/CenterCombo/ComboInUrFace
onready var sweet_label = $UI/SweetsCombo
onready var multiplier_label = $UI/Multiplier
onready var fire = $FireContainer/Fire/Fire
onready var fire_topper = $FireContainer/Fire/FireTopper
onready var burnable_bread = $FireContainer/Fire/BurnableBread
onready var toast_percent = $UI/ToastPercent
onready var ui = $UI
onready var sugar_rush_percent = $UI/SugarRushContainer/SugarRush/SugarPercent
onready var tween = $Tween

onready var song_title = $UI/SongTitle
onready var artist = $UI/Artist
onready var time = $UI/Time
onready var bpm = $UI/BPM
onready var fade = $UI/Fade
onready var song_progress = $UI/SongProgress
onready var limited_vis = $UI/LimitedVisibility

onready var ovens : Array = [
	oven1,
	oven2,
	oven3,
	oven4
]
onready var receivers : Array = [
	receiver1,
	receiver2,
	receiver3,
	receiver4
]

onready var receiver_container = $CenterReciever/RecieverContainer
onready var gameover_timer = $GameOver

var points : int = 0
var misses : float = 0
var consecutive_hits : int = 0
var consecutive_sweets : int = 0
var multiplier : float = 0.0
var toast_multiplier : int = 1

# Song data stuff
var current_beat : float = 0.0
var tempo : float = 0.0

var fire_anim_index : int = 0
var fire_current_frame : float = 0.0

# Thanks for the code John lmao 
func load_data(path):
	var file = File.new()
	file.open(path, file.READ)
	var contents : String = file.get_as_text()
	var data : Dictionary = parse_json(contents)
	return data

#func _input(event):
#	if event.is_action_pressed("ui_cancel") and start_delay.is_stopped():
#		add_child(MENU.instance(), true)
#		get_tree().paused = true

func delete_missed_bread(area : Area2D):
	#print("you missed :)")
	var smoke = SMOKE.instance()
	smoke.transform = area.get_global_transform()
	smoke.position += Vector2(0, 50)
	add_child(smoke, true)
	area.get_parent().delete(false, -100)
	misses += 0.5
	#print(points)


# ew
func _physics_process(delta):
	toast_multiplier = max(0, toast_multiplier)
	consecutive_hits = max(0, consecutive_hits)
	consecutive_sweets = max(0, consecutive_sweets)
	toast_percent.value = toast_multiplier
	point_label.text = "POINTS: " + String(points)
	hit_label.text = "COMBO: " + String(consecutive_hits) + "X"
	sweet_label.text = "SWEETS: " + String(consecutive_sweets) + "X"
	multiplier_label.text = "MULTIPLIER: " + String(multiplier) + "X"
	if not false:#ScoreTracker.cheats[1]["value"]:
		tween.interpolate_property(fire, "scale", fire.scale, Vector2(1, -(misses)*0.154-0.144), 0.1, Tween.TRANS_LINEAR)
		tween.start()
		fire_anim_index+=1
		if fire_anim_index >= 7:
			fire_current_frame += 1.0
			fire_anim_index = 0.0
		if fire_current_frame >= 6.0:
			fire_current_frame = 0.0
	fire.frame = fire_current_frame
	fire_topper.frame = fire_current_frame
	fire_topper.offset.y = fire.scale.y*60*6.8
	song_progress.value = MusicPlayer.get_playback_position()/MusicPlayer.stream.get_length()
	#if misses >= 5:
	#	point_label.text = "haha u died"

func _process(delta):
	current_beat = tempo * 60 * MusicPlayer.get_playback_position()
	print(current_beat)
	print("Time is: ", current_beat)

func consecutive_combos():
	multiplier = (max(1, (consecutive_hits / 2) + (consecutive_sweets * 1.5) * toast_multiplier))
	if consecutive_hits > 5:
		combo_total.visible = true
	else:
		combo_total.visible = false
	#if consecutive_sweets >= 20:
		# I really don't want a players fire to go out if they do TOO good, so 
		#this is really low
		#misses -= 0.01
		# I've reconsidered this a bit. Imagine a perfect run? They couldn't use TOAST at ALL! No fire dulling, get gud or don't use TOAST
	# Also SugarRush lol
	sugar_rush_percent.value = consecutive_sweets
	misses = max(0, misses)
	combo_total.text = String(consecutive_hits)
	tween.interpolate_property(combo_total, "rect_scale", Vector2(1, 1), Vector2(1.25, 1.25), 0.2, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	tween.interpolate_property(combo_total, "rect_scale", Vector2(1.25, 1.25), Vector2(1, 1), 0.2, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	tween.start()
	combo_total.add_color_override("font_color", Color(0.772, 0.788, 0.321, 1) if consecutive_hits >= 100 else Color(1, 1, 1, 1))

#func bop_bread():
#	if pattern.size() > current_bop:
#		bread_bop_timer.wait_time *= pattern[current_bop]["beat_time"]
#		current_bop += 1
#		burnable_bread.pulse_with_beat()

func burn_bread_on_perfect_miss():
	# Hacky, w/e idgaf
	misses+=1

func burn_bread(area : Node, override : bool = false):
	if area.is_in_group("Fire") or override:
		var smoke = SMOKE.instance()
		smoke.transform = burnable_bread.get_global_transform()
		add_child(smoke, true)
		burnable_bread.burn_bread()

func game_over():
	if not ScoreTracker.cheats[0]["value"] or not ScoreTracker.cheats[1]["value"]:
		ScoreTracker.set_scores(points, song_data["SONG_INFO"]["Name"])
	set_process_input(false)
#	timer.stop()
#	bread_bop_timer.stop()
	tween.interpolate_property(MusicPlayer, "pitch_scale", 1, 0.01, 1.0, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tween.interpolate_property(MusicPlayer, "volume_db", 0, -20, 1.0, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tween.interpolate_property(self, "points", points, 0, 1.0, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tween.interpolate_property(self, "toast_multiplier", toast_multiplier, 0, 1.0, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tween.interpolate_property(self, "multiplier", multiplier, 0, 1.0, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tween.interpolate_property(self, "consecutive_hits", consecutive_hits, 0, 1.0, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tween.interpolate_property(self, "consecutive_sweets", consecutive_sweets, 0, 1.0, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tween.start()
#	gameover_timer.start()

func pause_game():
	var menu = MENU.instance()
	menu.can_resume = false
	add_child(menu, true)
	get_tree().paused = true

func toasting(multiplier):
	toast_multiplier += multiplier

func toast_bread(area : Node, amount : int):
	if area.is_in_group("Fire"):
		burnable_bread.toast(amount)

func untoast_bread(area : Node, amount : int):
	if area.is_in_group("Fire"):
		burnable_bread.toast(-amount)

func _ready():
	MusicPlayer.pitch_scale = 1.0
	MusicPlayer.volume_db = 0.0
	#if (ScoreTracker.cheats[3]["value"] or ScoreTracker.cheats[3]["sub-cheat"]["value"]):
	#	gameover_timer.wait_time = 0.5
	#if ScoreTracker.cheats[3]["value"]:
	#	points = 0
	#	misses = 5.0
	#limited_vis.visible = ScoreTracker.cheats[2]["value"]
	#fade.visible = true
	#song_data = load_data(raw_song_data)
	#MusicPlayer.stream = load(song_data["SONG_INFO"]["Song"])
	# Descent = 2 bps
#	timer.wait_time = bake_interval
#	bread_bop_timer.wait_time = bake_interval
	#pattern = song_data["PATTERN"]
	#for x in range(0, 4):
		#ovens[x].connect("bread_spawned", receivers[x], "add_bread_to_array")
		#deletion_zone.connect("area_entered", receivers[x], "remove_bread_from_array")
	deletion_zone.connect("area_entered", self, "delete_missed_bread")
	burnable_bread.burn_area.connect("area_entered", self, "burn_bread")
	burnable_bread.toast1.connect("area_entered", self, "toast_bread", [1])
	burnable_bread.toast2.connect("area_entered", self, "toast_bread", [2])
	burnable_bread.toast3.connect("area_entered", self, "toast_bread", [3])
	burnable_bread.toast1.connect("area_exited", self, "untoast_bread", [1])
	burnable_bread.toast2.connect("area_exited", self, "untoast_bread", [2])
	burnable_bread.toast3.connect("area_exited", self, "untoast_bread", [3])
	#timer.start()
#	timer.connect("timeout", self, "bake_bread")
#	bread_bop_timer.connect("timeout", self, "bop_bread")
	gameover_timer.connect("timeout", self, "pause_game")
	#time_begin = OS.get_ticks_usec()
	#time_delay = AudioServer.get_time_to_next_mix() + AudioServer.get_output_latency()
	tween.interpolate_property(fade, "color", Color(0, 0, 0, 1), Color(0, 0, 0, 0), 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.start()
	set_process_input(true)
	set_physics_process(true)
	# throw in the neat song credits here
	#song_title.text = song_data["SONG_INFO"]["Name"]
	#artist.text = song_data["SONG_INFO"]["Artist"]
	#time.text = "Length: " + song_data["SONG_INFO"]["Time"]
	#bpm.text = "BPM: " + String(song_data["SONG_INFO"]["BPM"])
	tween.interpolate_property(song_title, "rect_position", Vector2(1004, 32), Vector2(204, 32), 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.interpolate_property(artist, "rect_position", Vector2(-300, 86), Vector2(252, 86), 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.interpolate_property(time, "rect_position", Vector2(1004, 132), Vector2(284, 132), 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.interpolate_property(bpm, "rect_position", Vector2(-300, 178), Vector2(296, 178), 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.interpolate_property(song_title, "rect_position", Vector2(204, 32), Vector2(188, 32), 1.5, Tween.TRANS_LINEAR, Tween.EASE_IN, 0.5)
	tween.interpolate_property(artist, "rect_position", Vector2(252, 86), Vector2(268, 86), 1.5, Tween.TRANS_LINEAR, Tween.EASE_IN, 0.5)
	tween.interpolate_property(time, "rect_position", Vector2(284, 132), Vector2(268, 132), 1.5, Tween.TRANS_LINEAR, Tween.EASE_IN, 0.5)
	tween.interpolate_property(bpm, "rect_position", Vector2(296, 178), Vector2(312, 178), 1.5, Tween.TRANS_LINEAR, Tween.EASE_IN, 0.5)
	tween.interpolate_property(song_title, "rect_position", Vector2(220, 32), Vector2(-300, 32), 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN, 2.0)
	tween.interpolate_property(artist, "rect_position", Vector2(268, 86), Vector2(1004, 86), 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN, 2.0)
	tween.interpolate_property(time, "rect_position", Vector2(300, 132), Vector2(-300, 132), 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN, 2.0)
	tween.interpolate_property(bpm, "rect_position", Vector2(312, 178), Vector2(1004, 178), 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN, 2.0)
	tween.start()
	#yield(tween, "tween_all_completed")
	#start_delay.wait_time = song_data["SONG_INFO"]["Start_Delay"] * 3
	#start_delay.start()
	#yield(start_delay, "timeout")
	#start_delay.wait_time = song_data["SONG_INFO"]["Start_Delay"] * 2
	#start_delay.start()
	#yield(start_delay, "timeout")
	MusicPlayer.play()
	#bread_bop_timer.start()
	burnable_bread.pulse_with_beat()
