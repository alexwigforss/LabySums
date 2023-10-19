extends Area2D

func _ready():
	pass # Replace with function body.

func _on_Area2d_body_entered(body):
	if body.is_in_group("player"):
		queue_free()# Replace with function body.


func _on_Area2d_area_entered():
	pass # Replace with function body.
