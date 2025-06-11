extends Area2D

export var strength = 1

signal nomatch(nr)
signal doormatch(nr)

func _ready():
	$Label.text = str(strength)

func _on_door_body_entered(body, _extra_arg_0): 
	var emitting_actor = get_node("/root/colworld/player")
	var plpower = emitting_actor.strength

	if body.get_name() == "player" && plpower == strength:
		print(plpower," ",self,"removed",_extra_arg_0)
		emit_signal("doormatch", strength)
		queue_free()
	elif body.get_name() == "player" && plpower != strength:
		emit_signal("nomatch", strength)	
