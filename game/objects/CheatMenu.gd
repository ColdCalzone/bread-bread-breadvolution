extends Control

onready var show_cheats = $ShowCheats
onready var tween = $Tween
onready var bg = $CheatsContainer/Cheats/ColorRect
onready var cheats = $CheatsContainer/Cheats

onready var menu_theme = preload("res://objects/CheatMenuTheme.tres")

var currently_showing = false

var sub_cheats : Array = []

var disabled_cheats : Array = []

class_name CheatMenu

func toggle_cheats_shown():
	currently_showing = !currently_showing
	if currently_showing:
		tween.interpolate_property(self, "rect_position", Vector2(0, 0), Vector2(256, 0), 0.4, Tween.TRANS_EXPO)
	if !currently_showing:
		tween.interpolate_property(self, "rect_position", Vector2(256, 0), Vector2(0, 0), 0.4, Tween.TRANS_EXPO)
	tween.start()

func toggle_cheat(value : bool, cheat : String) -> bool:
	if ScoreTracker.set_cheat(value, cheat):
		if value:
			if cheat == "Sudden Death":
				ScoreTracker.set_cheat(false, "No Fail")
				ScoreTracker.set_cheat(false, "Aimbot")
				if not "No Fail" in disabled_cheats: disabled_cheats.append("No Fail")
				if not "Aimbot" in disabled_cheats: disabled_cheats.append("Aimbot")
			for cheats in ScoreTracker.cheats:
				if cheats.name == cheat:
					if cheats.has("sub-cheat") and not cheats in sub_cheats:
						sub_cheats.append(cheats)
			draw_all_cheats()
			return true
		else:
			if cheat == "Sudden Death":
				disabled_cheats.erase("No Fail")
				disabled_cheats.erase("Aimbot")
			for cheats in ScoreTracker.cheats:
				if cheats.name == cheat:
					if cheats.has("sub-cheat"):
						sub_cheats.erase(cheats)
			draw_all_cheats()
			return true
	return false

func _physics_process(delta):
	bg.rect_size = cheats.rect_size

func draw_all_cheats():
	for cheat in cheats.get_children():
		if cheat.name == "ColorRect": continue
		cheat.queue_free()
	yield(get_tree().create_timer(0.0001), "timeout")
	for cheat in ScoreTracker.cheats:
		cheats.add_child(VBoxContainer.new(), true)
		get_node("CheatsContainer/Cheats/VBoxContainer").add_child(CheckButton.new(), true)
		var vbox = get_node("CheatsContainer/Cheats/VBoxContainer")
		vbox.name = cheat["name"]
		var button = get_node("CheatsContainer/Cheats/"+vbox.name+"/CheckButton")
		button.text = cheat["name"]
		button.pressed = cheat["value"]
		button.set("custom_fonts/font", load("res://objects/KarmaticArcade.tres"))
		button.connect("toggled", self, "toggle_cheat", [button.text])
		if cheat.has("sub-cheat") and not cheat in sub_cheats and cheat["value"]:
			sub_cheats.append(cheat)
		disable_incompatible_cheats()
		button.disabled = cheat["name"] in disabled_cheats
		button.theme = menu_theme
		button.hint_tooltip = cheat["tooltip"]
		if cheat in sub_cheats:
			cheats.add_child(VBoxContainer.new(), true)
			get_node("CheatsContainer/Cheats/VBoxContainer").add_child(CheckButton.new(), true)
			vbox = get_node("CheatsContainer/Cheats/VBoxContainer")
			vbox.name = cheat["sub-cheat"]["name"]
			button = get_node("CheatsContainer/Cheats/"+vbox.name+"/CheckButton")
			button.text = cheat["sub-cheat"]["name"]
			button.pressed = cheat["sub-cheat"]["value"]
			button.set("custom_fonts/font", load("res://objects/KarmaticArcade.tres"))
			button.connect("toggled", self, "toggle_cheat", [button.text])
			button.theme = menu_theme
			button.hint_tooltip = cheat["sub-cheat"]["tooltip"]

func disable_incompatible_cheats():
	for cheat in ScoreTracker.cheats:
		if cheat["name"] == "Sudden Death" and cheat["value"]:
			if not "No Fail" in disabled_cheats: disabled_cheats.append("No Fail")
			if not "Aimbot" in disabled_cheats: disabled_cheats.append("Aimbot")

func _ready():
	show_cheats.connect("pressed", self, "toggle_cheats_shown")
	#ughhhhh I gotta do this because... wait I can just make a function to get 
	#the disabled cheats... dammit
	#draw_all_cheats()
	#yield(get_tree().create_timer(0.0001), "timeout")
	disable_incompatible_cheats()
	draw_all_cheats()
