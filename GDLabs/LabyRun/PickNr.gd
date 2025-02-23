extends Area2D
export var player: NodePath

signal picked(nr)

# In the script of the instantiated scene
var value: int

func init_value(new_value):
	value = new_value

func _ready():
	$Label.text = str(value)

func _on_pickNum_body_entered(body):
	if body.is_in_group("player"):
		var sibling_node = get_parent().get_parent().get_node("pickOps")  # Ersätt "SiblingNodeName" med det faktiska namnet
		if sibling_node is Node2D:
			sibling_node.modulate.a = 1  # Ändrar alpha-värdet till 0.5
		var parent_node = get_parent()  # Hämtar föräldranoden
		if parent_node is Node2D:  # Kontrollerar om föräldranoden är en Node2D
			parent_node.modulate.a = 0.5  # Ändrar alpha-värdet till 0.5
		emit_signal("picked", value)
		queue_free()# Replace with function body.
