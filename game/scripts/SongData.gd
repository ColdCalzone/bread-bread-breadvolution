extends Node

var current_level : String

var songs : Dictionary = {
	"Descent": "res://song_data/Descent.tres",
	"GoingUp": "res://song_data/GoingUp.tres",
	"Loadout": "res://song_data/Loadout.tres"
}

func get_level() -> String:
	return current_level

func set_level(level : String) -> bool:
	if songs.has(level):
		current_level = songs[level]
		return true
	return false
