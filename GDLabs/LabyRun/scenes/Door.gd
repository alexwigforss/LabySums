extends Area2D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

#func _on_Area2D_body_entered(body: Node) -> void:
#	if body.is_in_group("player"):
#		queue_free()


func _on_Area2d_body_entered(body):
	if body.is_in_group("player"):
		queue_free()# Replace with function body.
