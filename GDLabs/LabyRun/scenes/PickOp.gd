extends Area2D

# Declare member variables here. Examples:
var ops = ['+','-','*','/']
export var opnr = 0
export var player: NodePath

signal op_picked(op)

# In the script of the instantiated scene
var value: int

func init_value(new_value):
	value = new_value

func _ready():
	$Label.text = ops[opnr]

func _on_pickOp_body_entered(body):
	if body.is_in_group("player"):
		
		var node_path = get_path()
		print("Objektets plats i nodträdet: ", node_path)
		
		var sibling_node = get_parent().get_parent().get_node("pickNums")  # Ersätt "SiblingNodeName" med det faktiska namnet
		if sibling_node is Node2D:
			sibling_node.modulate.a = 1  # Ändrar alpha-värdet till 0.5
		var parent_node = get_parent()  # Hämtar föräldranoden
		if parent_node is Node2D:  # Kontrollerar om föräldranoden är en Node2D
			parent_node.modulate.a = 0.5  # Ändrar alpha-värdet till 0.5
		emit_signal("op_picked", ops[opnr])
		queue_free()# Replace with function body.

func set_opnr(n):
	opnr = n
