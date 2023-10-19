extends Area2D

export var strength = 5

func _ready():
	$Label.text = str(strength)

func _on_MonsterArea2D_body_entered(body):
	var emitting_scene = get_node("/root/colworld/player")
	var plpower = emitting_scene.strength

	if body.get_name() == "player" && plpower >= strength:
		print(plpower," ",self,"removed")
		queue_free()# Replace with function body.
