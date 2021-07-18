extends Control

onready var chart_container = $Hbox/GridChart

const HIGHLIGHT_COLOR : Color = Color("8f3737")
var loading_chart : bool = false

onready var bpm_box = $Hbox/VboxDetails/BPM/SpinBox
var bpm : float = 60.0

const default_notes : Array = [
	[0,0,0,0],
	[0,0,0,0],
	[0,0,0,0],
	[0,0,0,0],
	[0,0,0,0],
	[0,0,0,0],
	[0,0,0,0],
	[0,0,0,0],
	[0,0,0,0],
	[0,0,0,0],
	[0,0,0,0],
	[0,0,0,0],
	[0,0,0,0],
	[0,0,0,0],
	[0,0,0,0],
	[0,0,0,0],
]

var pages : Array = []
var page : int = 1
var max_page : int = 1
var beats : float = 0.0
var current_beat : float = 0.0
var last_beat : float = 0.0

var edit_slider : bool = false
var stored_val : float = 0.0

var audio : AudioStream = load("res://sfx/bloop.ogg")

onready var page_select : SpinBox = $PageSelect/Label

onready var music_progress : HSlider = $VboxMath/Audio/HSlider
onready var play_pause : Button = $VboxMath/Audio/Button

onready var recommended_pages : Label = $VboxMath/CalculatedPages/Label2

onready var play_pause_sprites : Array = [preload("res://sprites/Play.png"), preload("res://sprites/Pause.png")]

enum {NONE, LEFT, DOWN, UP, RIGHT}

onready var file_dialog = $File/FileDialog
onready var file_button = $Hbox/VboxDetails/FileSelect/Button

# Song Details
onready var song_name = $Hbox/VboxDetails/Name/TextEdit
onready var artist = $Hbox/VboxDetails/Artist/TextEdit
onready var start_delay = $Hbox/VboxDetails/StartDelay/SpinBox
var song_path : String

# Used for the highlighting
var chart_lines : Array = []

# Called when the node enters the scene tree for the first time.
func _ready():
	#OS.window_fullscreen = true
	MusicPlayer.stream = audio
	MusicPlayer.connect("finished", self, "reset_audio_player")
	bpm_box.connect("value_changed", self, "bpm_changed")
	pages.append(default_notes.duplicate(true))
	var buttons = get_tree().get_nodes_in_group("ChartButton")
	var line := []
	for i in range(buttons.size()):
		line.append(buttons[i].get_parent())
		if line.size() == 4:
			chart_lines.append(line.duplicate())
			line = []
		buttons[i].connect("button_up", self, "set_note_value", [i])

func set_note_value(id : int):
	pages[page - 1][id / 4][id % 4] = int(get_tree().get_nodes_in_group("ChartButton")[id].pressed)

func _input(event : InputEvent):
	if event is InputEventKey:
		if event.is_action_pressed("k_code_right"):
			page_select.value += 1
		if event.is_action_pressed("k_code_left"):
			page_select.value -= 1

func _process(delta):
	if MusicPlayer.is_playing():
		if !edit_slider:
			music_progress.value = MusicPlayer.get_playback_position()/MusicPlayer.stream.get_length()
		if current_beat < last_beat:
			last_beat = 0
			page_select.value = 1
			return
		current_beat = MusicPlayer.get_playback_position() * bpm / 60
		if last_beat < floor(current_beat):
			last_beat = current_beat
			page_select.value = last_beat + 1

		for line in chart_lines:
			for note in line:
				note.set_modulate(Color.white)

		for i in range(chart_lines[int(floor(current_beat * 16)) % 16].size()):
			chart_lines[int(floor(current_beat * 16)) % 16][i].set_modulate(HIGHLIGHT_COLOR)
			
		
	else:
		current_beat = 0

func bpm_changed(amount : int):
	bpm = amount
	beats = audio.get_length() / 60 * bpm
	recommended_pages.text = String(ceil(beats))


func _on_file_select_button():
	file_dialog.mode = FileDialog.MODE_OPEN_FILE
	file_dialog.add_filter("*.ogg ; OGG Vorbis audio file")
	file_dialog.add_filter("*.wav ; WAV audio file")
	file_dialog.popup()

func _on_save_button():
	file_dialog.mode = FileDialog.MODE_SAVE_FILE
	file_dialog.add_filter("*.bread ; BBB chart file")
	file_dialog.popup()

func _on_load_button_up():
	file_dialog.mode = FileDialog.MODE_OPEN_FILE
	loading_chart = true
	file_dialog.add_filter("*.bread ; BBB chart file")
	file_dialog.popup()

func _on_FileDialog_file_selected(path : String):
	file_dialog.clear_filters()
	if file_dialog.mode == FileDialog.MODE_OPEN_FILE:
		if loading_chart:
			var file = File.new()
			if !file.open(path, file.READ):
				var content = JSON.parse(file.get_as_text()).result
				song_path = content["SONG_INFO"]["Song"]
				audio = load(song_path)
				MusicPlayer.stream = audio
				file_button.text = song_path.rsplit("/", false, 1)[1]
				song_name.text = content["SONG_INFO"]["Name"]
				artist.text = content["SONG_INFO"]["Artist"]
				bpm_box.value = content["SONG_INFO"]["BPM"]
				
				beats = audio.get_length() / 60 * bpm
				recommended_pages.text = String(ceil(beats))
				
				start_delay.value = content["SONG_INFO"]["Start_Delay"]
				var page_ := []
				pages = []
				for line in content["PATTERN"]:
					page_.append(line)
					if page_.size() == 16:
						pages.append(page_.duplicate())
						page_ = []
				file.close()
				var chart_buttons = get_tree().get_nodes_in_group("ChartButton")
				for note in range(chart_buttons.size()):
					chart_buttons[note].pressed = pages[page - 1][note / 4][note % 4] != 0
		else:
			song_path = path
			file_button.text = path.rsplit("/", false, 1)[1]
			audio = load(path)
			MusicPlayer.stream = audio
			beats = audio.get_length() / 60 * bpm
			recommended_pages.text = String(ceil(beats))
	else:
		var file = File.new()
		if !file.open(path, File.WRITE):
			var json : Dictionary = {}
			json["SONG_INFO"] = {
				"Name" : song_name.text,
				"Artist" : artist.text,
				"Song" : song_path,
				"BPM" : bpm,
				"Length" : audio.get_length(),
				"Start_Delay" : start_delay.value,
			}
			json["PATTERN"] = []
			for page in pages:
				for line in page:
					json["PATTERN"].append(line)
			file.store_string(JSON.print(json))
			file.close()


func _on_Label_value_changed(value : float):
	page = value
	if page > max_page:
		for _x in range(page - max_page):
			pages.append(default_notes.duplicate(true))
		max_page = page
	var chart_buttons := get_tree().get_nodes_in_group("ChartButton")
	for note in range(chart_buttons.size()):
		chart_buttons[note].pressed = pages[page - 1][note / 4][note % 4] != 0
	for line in chart_lines:
		for note in line:
			note.modulate = Color.white


func _on_play_button_up():
	play_pause.icon = play_pause_sprites[int(play_pause.pressed)]
	if !MusicPlayer.playing:
		for line in chart_lines:
			for item in line:
				item.set_modulate(Color.white)
		page_select.value = 1
		MusicPlayer.play()
	else:
		MusicPlayer.stop()

func reset_audio_player():
	play_pause.pressed = false
	play_pause.icon = play_pause_sprites[0]
	music_progress.value = 0


func _on_HSlider_gui_input(event : InputEvent):
	if event.is_action_pressed("left_mouse"):
		stored_val = MusicPlayer.get_playback_position()
		edit_slider = true
	elif event.is_action_released("left_mouse"):
		MusicPlayer.seek(stored_val * audio.get_length())
		edit_slider = false


func _on_HSlider_value_changed(value : float):
	if edit_slider:
		stored_val = value

func _on_HSpeed_value_changed(value : float):
	MusicPlayer.pitch_scale = value
