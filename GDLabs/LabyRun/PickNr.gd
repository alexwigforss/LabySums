extends Area2D

# Declare member variables here. Examples:
export var number = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	$Label.text = str(number)

func _on_Area2d_body_entered(body):
	if body.is_in_group("player"):
		queue_free()# Replace with function body.

#func _on_Area2d_area_entered():
#	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
