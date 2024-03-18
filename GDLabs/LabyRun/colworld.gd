extends Node2D

var _label

func _ready():
	_label = get_node("player/Camera2D/ColorRect/MainLabel")

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
