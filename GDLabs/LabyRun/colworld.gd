extends Node2D

func _on_goal_body_entered(body):
	var emitting_scene = get_node("/root/colworld/player")
	var plpower = emitting_scene.strength

	if body.get_name() == "player" && plpower == 20:
		$youwin.show()
