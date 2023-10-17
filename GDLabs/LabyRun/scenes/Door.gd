extends Area2D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _on_player_door_signal(plstr,body):
	if plstr > 1 && body.get_name() == "player":
		queue_free()# Replace with function body.
		
