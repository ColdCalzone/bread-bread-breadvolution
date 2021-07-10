extends Control

onready var chart_container = $Hbox/GridChart
onready var bpm = $Hbox/VboxDetails/BPM/SpinBox

var notes : Array = []
var page : int = 1
var beats : float = 0.0

var audio : AudioStream = load("res://sfx/bloop.ogg")

onready var page_select : Array = [$PageSelect/Left, $PageSelect/Right, $PageSelect/Label]

onready var music_progress : HSlider = $VboxMath/Audio/HSlider
onready var play_pause : Button = $VboxMath/Audio/Button

onready var recommended_pages : Label = $VboxMath/CalculatedPages/Label2

onready var play_pause_sprites : Array = [preload("res://sprites/Play.png"), preload("res://sprites/Pause.png")]

enum {NONE, LEFT, DOWN, UP, RIGHT}

onready var file_dialog = $File/FileDialog
onready var file_button = $Hbox/VboxDetails/FileSelect/Button

# Called when the node enters the scene tree for the first time.
func _ready():
	OS.window_fullscreen = true
	MusicPlayer.stream = audio
	page_select[0].connect("button_up", self, "flip_page", [-1])
	page_select[1].connect("button_up", self, "flip_page", [1])
	MusicPlayer.connect("finished", self, "reset_audio_player")
	bpm.connect("value_changed", self, "bpm_changed")
	for i in range(64):
		notes.append(NONE)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func bpm_changed(amount : int):
	beats = audio.get_length() / 60 * amount
	recommended_pages.text = String(ceil(beats / 16))

func flip_page(amount : int):
	page += amount
	if page + amount < 1:
		page = 1
	page_select[2].value = page

func _on_file_select_button():
	file_dialog.mode = FileDialog.MODE_OPEN_FILE
	file_dialog.popup()

func _on_save_button():
	file_dialog.mode = FileDialog.MODE_SAVE_FILE
	file_dialog.popup()

func _on_FileDialog_file_selected(path : String):
	file_button.text = path.rsplit("/", false, 1)[1]
	audio = load(path)
	MusicPlayer.stream = audio
	beats = audio.get_length() / 60 * bpm.value
	recommended_pages.text = String(ceil(beats / 16))


func _on_Label_value_changed(value : float):
	page = value


func _on_play_button_up():
	play_pause.icon = play_pause_sprites[int(play_pause.pressed)]
	if !MusicPlayer.playing:
		MusicPlayer.play()
	else:
		MusicPlayer.stop()

func _process(delta : float) -> void:
	music_progress.value = MusicPlayer.get_playback_position()/MusicPlayer.stream.get_length()

func reset_audio_player():
	play_pause.pressed = false
	music_progress.value = 0
