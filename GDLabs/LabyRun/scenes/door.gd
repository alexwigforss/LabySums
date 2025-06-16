extends Area2D

export var strength = 1

signal nomatch(nr)
signal doormatch(nr)

func _ready():
	$Label.text = str(strength)

func set_streangth(st):
	strength = st
	$Label.text = str(strength)

func get_next_map():
	var current_map = get_parent()
	var root = current_map.get_parent()
	var children = root.get_children()
	var index = children.find(current_map)
	
	if index >= 0 and index < children.size() - 1:
		return children[index + 1]  # Nästa Map
	return null  # Finns ingen nästa

func _on_door_body_entered(body, _extra_arg_0): 
	var emitting_actor = get_node("/root/colworld/player")
	var plpower = emitting_actor.strength

	if body.get_name() == "player" && plpower == strength:
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
			
		print(plpower," ",self,"removed",_extra_arg_0)
		emit_signal("doormatch", strength)
		queue_free()
	elif body.get_name() == "player" && plpower != strength:
		emit_signal("nomatch", strength)	
