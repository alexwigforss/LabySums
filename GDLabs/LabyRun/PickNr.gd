class_name PickNum
extends Area2D
export var player: NodePath
onready var sprite = get_node("Sprite")
onready var over_lay_node = get_parent().get_parent().get_node("overLay")
signal picked(nr)
var overlay_sprite = Sprite.new()

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

	# Overlay sprite for highlighting the number
	overlay_sprite.texture = load("res://sprites/nums_trans.png")
	overlay_sprite.region_enabled = true
	overlay_sprite.region_rect = sprite.region_rect # Use same region as main sprite
	overlay_sprite.position = position
	overlay_sprite.z_index = 10

	over_lay_node.add_child(overlay_sprite)

func _on_pickNum_body_entered(body):
	if not body.is_in_group("player"):
		return

	# ❗ Check if player is allowed to pick numbers (i.e., mask bit 2 is ON)
	if not body.get_collision_mask_bit(1):
		print("Ignored number: player not allowed to pick numbers right now")
		return  # Do NOT pick up or free
		
	# Allow pick-up logic to proceed
	var sibling_node = get_parent().get_parent().get_node("pickOps")
	if sibling_node is Node2D:
		sibling_node.modulate.a = 1
		print(sibling_node.get_path(),sibling_node.modulate)
	
	# if over_lay_node is Node2D:
	# 	over_lay_node.modulate.a = 1.0
	# 	print(over_lay_node.get_path(),over_lay_node.modulate)

	var parent_node = get_parent()
	if parent_node is Node2D:
		parent_node.modulate.a = 0.5
		print(parent_node.get_path(),parent_node.modulate)
	if overlay_sprite:
		overlay_sprite.queue_free()
	emit_signal("picked", value)
	queue_free()
