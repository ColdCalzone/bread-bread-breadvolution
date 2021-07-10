extends GridContainer

onready var recievers : Array = [
	$BreadReciever,
	$BreadReciever2,
	$BreadReciever3,
	$BreadReciever4
]


func _input(event : InputEvent) -> void:
	if not event is InputEventKey: return
	if event.is_action_pressed("ui_left"):
		recievers[0].press()
	elif event.is_action_released("ui_left"):
		recievers[0].release()
	if event.is_action_pressed("ui_down"):
		recievers[1].press()
	elif event.is_action_released("ui_down"):
		recievers[1].release()
	if event.is_action_pressed("ui_up"):
		recievers[2].press()
	elif event.is_action_released("ui_up"):
		recievers[2].release()
	if event.is_action_pressed("ui_right"):
		recievers[3].press()
	elif event.is_action_released("ui_right"):
		recievers[3].release()

