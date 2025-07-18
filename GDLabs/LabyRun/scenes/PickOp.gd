class_name PickOp
extends Area2D

# Declare member variables here. Examples:
var ops = ['+','-','*','/']
export var opnr = 0
export var player: NodePath

signal op_picked(op)
onready var sprite = get_node("Sprite")
onready var over_lay_node = get_parent().get_parent().get_node("overLay")
var overlay_sprite = Sprite.new()

# In the script of the instantiated scene
var value: int

func init_value(new_value):
	value = new_value

func _ready():
	# $Label.text = ops[opnr]
	if opnr == 0:
		# +
		sprite.region_rect = Rect2(32, 0, 16, 16)
	if opnr == 1:
		# -
		sprite.region_rect = Rect2(48, 0, 16, 16)
	if opnr == 2:
		# *
		sprite.region_rect = Rect2(16, 0, 16, 16)
	if opnr == 3:
		# /
		sprite.region_rect = Rect2(0, 0, 16, 16)

	# Overlay sprite for highlighting the operator
	overlay_sprite.texture = load("res://sprites/nums_trans.png")
	overlay_sprite.region_enabled = true
	overlay_sprite.region_rect = sprite.region_rect # Use same region as main sprite
	overlay_sprite.position = position
	overlay_sprite.z_index = 10 # Ensure it's above the main sprite

	over_lay_node.add_child(overlay_sprite)

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
		if overlay_sprite:
			overlay_sprite.queue_free()
		emit_signal("op_picked", ops[opnr])
		queue_free()# Replace with function body.

func set_opnr(n):
	opnr = n
