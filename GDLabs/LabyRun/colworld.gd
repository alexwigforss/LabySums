extends Node2D

var _label
var _current
var active_map_nr = 1

func _ready():
	_label = get_node("player/Camera2D/ColorRect/MainLabel")
	_current = get_node("/root/colworld/Map" + str(active_map_nr))
	
func _on_goal_body_entered(body):
	var emitting_scene = get_node("/root/colworld/player")
	var plpower = emitting_scene.strength

	if body.get_name() == "player" && plpower == 10:
		_label.text = "An door has opened"
	elif body.get_name() == "player" && plpower == 10:
		_label.text = "The key has to be an exact match"

func _on_ResetButton_pressed():
	get_tree().reload_current_scene()


func _on_door_nomatch(nr):
	_label.text = "Only " + str(nr) + " may pass"


func _on_door_match(_nr):
	active_map_nr += 1
	var previous = get_node("/root/colworld/Map"+ str(active_map_nr-1))  # Ersätt "SiblingNodeName" med det faktiska namnet
	if previous is Node2D:
		previous.modulate.a = 0.5  # Ändrar alpha-värdet till 0.5
	var next = get_node("/root/colworld/Map"+ str(active_map_nr))  # Ersätt "SiblingNodeName" med det faktiska namnet
	if next is Node2D:
		next.modulate.a = 1  # Ändrar alpha-värdet till 0.5
