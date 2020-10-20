extends Node

var scores : Dictionary
var completion : Dictionary
var cheats : Array
var cheats_enabled : bool

const SCORE_PATH = "user://scores.json"
const CONFIG_PATH = "user://settings.cfg"
const CHEAT_PATH = "user://cheats.json"
const COMPLETION_PATH = "user://completion.json"
const UPDATE_CHECK = "user://updated"

var config : ConfigFile

var volume : float
var fullscreen : bool

func load_config():
	config = ConfigFile.new()
	var err = config.load(CONFIG_PATH)
	if err == ERR_FILE_NOT_FOUND:
		err = config.save(CONFIG_PATH)
	if err == OK:
		volume = config.get_value("sound", "music_volume", 1)
		fullscreen = config.get_value("graphics", "fullscreen", false)
		cheats_enabled = config.get_value("game", "cheats_enabled", false)
		OS.set_window_fullscreen(fullscreen)
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear2db(volume))

func enable_cheats():
	config.set_value("game", "cheats_enabled", true)
	ScoreTracker.cheats_enabled = config.get_value("game", "cheats_enabled", false)
	config.save(CONFIG_PATH)

func get_score(level : String):
	if scores.has(level):
		return scores[level] if scores[level] > 0 else 0
	return "Error"

# Add Time and Toast too, Gold star for max toast and Sugar Rush
func set_scores(new_score : int, level : String) -> bool:
	if scores.has(level):
		if scores[level] < new_score:
			scores[level] = new_score
			save_game()
			return true
	return false

func get_cheat(cheat_name : String):
	for cheat in cheats:
		if cheat["name"] == cheat_name:
			return cheat["value"]
	return false

func get_completion(level : String) -> Dictionary:
	return completion[level]

func set_completion(level : String, challenge : String, value : bool) -> bool:
	if completion.has(level):
		if completion[level].has(challenge):
			completion[level][challenge] = value
			save_game()
			return true
	return false

func set_cheat(value : bool, cheat_name : String) -> bool:
	for cheat in cheats:
		if cheat["name"] == cheat_name:
			cheat["value"] = value
			save_game()
			return true
		elif cheat.has("sub-cheat"):
			if cheat["sub-cheat"]["name"] == cheat_name:
				cheat["sub-cheat"]["value"] = value
				save_game()
				return true
	return false

func any_level_complete() -> bool:
	# I wanted to use a for loop but it just return the name smh
	if completion["Descent"]["Beaten"] or completion["Loadout"]["Beaten"] or completion["GoingUp"]["Beaten"]:
			return true
	return false

# these DEFINITELY aren't stolen from F&F2
func new_game():
	scores = {
		"Descent": 0,
		"Loadout": 0,
		"GoingUp": 0
	}
	completion = {
		"Descent": {
			"Low Vis" : false,
			"Sudden Death" : false,
			"Beaten" : false,
			"Perfect" : false
		},
		"Loadout": {
			"Low Vis" : false,
			"Sudden Death" : false,
			"Beaten" : false,
			"Perfect" : false
		},
		"GoingUp": {
			"Beaten" : false,
			"Low Vis" : false,
			"Sudden Death" : false,
			"Perfect" : false
		}
	}
	cheats = [
		{
		"name": "Aimbot",
		"value": false,
		"tooltip": "Automatically hits perfect SWEETS. \nInvalidates your score."
		},
		{
		"name": "No Fail",
		"value": false,
		"tooltip": "Missed bread doesn't count as a miss. \nGood for practice. Invalidates your score."
		},
		{
		"name": "Limited Vis",
		"value": false,
		"tooltip": "Hides incoming bread. \nGrants an achievement on completion. \n"
		},
		{
		"name": "Sudden Death",
		"value": false,
		"tooltip": "Makes missing any bread cause a game over. \nGrants an achievement on completion.",
		"sub-cheat": {
			"name": "Perfect",
			"value": false,
			"tooltip": "Makes missing any sweet cause a game over. \nGrants an achievement on completion."
		}
		}
	]
	save_game()

func save_game():
	var data = scores
	var json = JSON.print(data)
	var file = File.new()
	file.open(SCORE_PATH, File.WRITE)
	file.store_string(json)
	file.close()
	data = cheats
	json = JSON.print(data)
	file.open(CHEAT_PATH, File.WRITE)
	file.store_string(json)
	data = completion
	json = JSON.print(data)
	file.open(COMPLETION_PATH, File.WRITE)
	file.store_string(json)
	file.open(UPDATE_CHECK, File.WRITE)
	file.store_string("GFIUHRIUGNREUGNREYUNHGIYERBNERIGUERNGFU")

func load_game():
	var file = File.new()
	if file.file_exists(SCORE_PATH):
		file.open(SCORE_PATH, File.READ)
		var content = file.get_as_text()
		file.close()
		var json = JSON.parse(content).result
		scores = json
	if file.file_exists(CHEAT_PATH):
		file.open(CHEAT_PATH, File.READ)
		var cheat_content = file.get_as_text()
		file.close()
		var json = JSON.parse(cheat_content).result
		cheats = json
	if file.file_exists(COMPLETION_PATH):
		file.open(COMPLETION_PATH, File.READ)
		var completion_content = file.get_as_text()
		file.close()
		var json = JSON.parse(completion_content).result
		completion = json
	if not file.file_exists(CHEAT_PATH) or not file.file_exists(SCORE_PATH) or not file.file_exists(COMPLETION_PATH) or not file.file_exists(UPDATE_CHECK):
		new_game()
