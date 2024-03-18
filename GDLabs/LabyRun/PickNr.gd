extends Area2D

# Declare member variables here. Examples:
export var number = 2
export var player: NodePath

func _on_Picknum_body_entered(body):
	var player = get_node(player)
	if player:
		var collected_number = 42  # Replace with the actual collected number
		player._on_number_collected(collected_number)
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	$Label.text = str(number)

func _on_Area2d_body_entered(body):
	if body.is_in_group("player"):
		queue_free()# Replace with function body.

func _on_Area2d_area_entered(_what):
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
