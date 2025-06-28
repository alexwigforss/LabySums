class_name PickNum
extends Area2D
export var player: NodePath
onready var sprite = get_node("Sprite")

signal picked(nr)

# In the script of the instantiated scene
var value: int

func init_value(new_value):
	value = new_value

func _ready():
	if value == 1:
		sprite.region_rect = Rect2(64, 0, 16, 16)
	if value == 2:
		sprite.region_rect = Rect2(80, 0, 16, 16)
	if value == 3:
		sprite.region_rect = Rect2(96, 0, 16, 16)
	if value == 4:
		sprite.region_rect = Rect2(112, 0, 16, 16)
	if value == 5:
		sprite.region_rect = Rect2(128, 0, 16, 16)
	if value == 6:
		sprite.region_rect = Rect2(144, 0, 16, 16)
	if value == 7:
		sprite.region_rect = Rect2(160, 0, 16, 16)
	if value == 8:
		sprite.region_rect = Rect2(176, 0, 16, 16)
	if value == 9:
		sprite.region_rect = Rect2(192, 0, 16, 16)
	if value == 0:
		sprite.region_rect = Rect2(208, 0, 16, 16)
	#$Label.text = str(value)

func _on_pickNum_body_entered(body):
	if body.is_in_group("player"):
		var sibling_node = get_parent().get_parent().get_node("pickOps")  # Ersätt "SiblingNodeName" med det faktiska namnet
		if sibling_node is Node2D:
			sibling_node.modulate.a = 1  # Ändrar alpha-värdet till 1
		var parent_node = get_parent()  # Hämtar föräldranoden
		if parent_node is Node2D:  # Kontrollerar om föräldranoden är en Node2D
			parent_node.modulate.a = 0.5  # Ändrar alpha-värdet till 0.5
		emit_signal("picked", value)
		queue_free()# Replace with function body.
