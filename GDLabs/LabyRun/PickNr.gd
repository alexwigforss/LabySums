extends Area2D

# Declare member variables here. Examples:
export var number = 2
export var player: NodePath

signal picked(nr)

func _on_Picknum_body_entered(body):
	var player = get_node(player)
	if player:
		var collected_number = 42  # Replace with the actual collected number
		player._on_number_collected(collected_number)

func _ready():
	$Label.text = str(number)

func _on_Area2d_body_entered(body):
	if body.is_in_group("player"):
		emit_signal("picked", number)
		queue_free()# Replace with function body.
