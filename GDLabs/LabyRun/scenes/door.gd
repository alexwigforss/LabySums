extends Area2D

export var strength = 1
var root
var current_map


func _ready():
	$Label.text = str(strength)
	current_map = get_parent()
	root = current_map.get_parent()

func set_streangth(st):
	strength = st
	$Label.text = str(strength)

func get_next_map():
	var children = root.get_children()
	var index = children.find(current_map)
	
	if index >= 0 and index < children.size() - 1:
		return children[index + 1]  # Nästa Map
	return null  # Finns ingen nästa

func _on_door_body_entered(body, _extra_arg_0): 
	var emitting_actor = get_node("/root/colworld/player")
	var plpower = emitting_actor.strength

	if body.get_name() == "player" && plpower == strength:
		root.update_current_segment()
		# Hämta TileMap parent
		var tilemap_parent = get_parent()
		if tilemap_parent:
			var color = tilemap_parent.modulate
			color.a = 0.5
			tilemap_parent.modulate = color
		# Hämta nästa TileMap som ligger under parent
		var next_map = get_next_map()
		if next_map:
			next_map.modulate = Color(1, 1, 1, 1.0)  # Ändra transparens t.ex.
		# Hämta Target Label
		var target_label = get_node("/root/colworld/player/Camera2D/Numpanel/TargetLabel")
		target_label.next_segment()
		

		print(plpower," ",self," removed ",_extra_arg_0)
		emitting_actor.reset_strength()
		queue_free()
	elif body.get_name() == "player" && plpower != strength:
		var msg_label = get_node("/root/colworld/player/Camera2D/ColorRect/MainLabel")
		msg_label.text = "Only " + str(strength) + " may pass"
