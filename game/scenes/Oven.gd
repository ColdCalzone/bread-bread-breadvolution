extends Control

class_name BreadSpawner

const BREAD = preload("res://scenes/Bread.tscn")

onready var spawn_location = $SpawnLocation

export(int) var rotation_direction : int = 0

signal bread_spawned(node)

func spawn_bread(speed : int) -> void:
	var new_bread = BREAD.instance()
	new_bread.rotation_direction = rotation_direction
	# TODO replace with variable
	new_bread.position = Vector2(get_parent().rect_position.x + rect_position.x, -64)
	new_bread.speed = speed
	# TODO replace with a variable
	get_tree().get_root().get_node("Game").call_deferred("add_child", new_bread)
	emit_signal("bread_spawned", new_bread.get_node("BreadArea"))

#func _ready() -> void:
	#spawn_bread()
