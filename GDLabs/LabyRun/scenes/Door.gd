extends Area2D

export var strength = 1

func _ready():
	$Label.text = str(strength)

func _on_door_body_entered(body, _extra_arg_0): 
	var emitting_scene = get_node("/root/colworld/player")
	var plpower = emitting_scene.strength

	if body.get_name() == "player" && plpower == strength:
		print(plpower," ",self,"removed")
		queue_free()# Replace with function body.
