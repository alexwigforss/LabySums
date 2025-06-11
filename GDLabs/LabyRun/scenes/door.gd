extends Area2D

export var strength = 1

signal nomatch(nr)
signal doormatch(nr)

func _ready():
	$Label.text = str(strength)

func _on_door_body_entered(body, _extra_arg_0): 
	var emitting_actor = get_node("/root/colworld/player")
	var plpower = emitting_actor.strength

	if body.get_name() == "player" && plpower == strength:
		# Hämta TileMap som ligger under parent
		var tilemap_parent = get_parent()
		if tilemap_parent:
			var color = tilemap_parent.modulate
			color.a = 0.5  # t.ex. 30% opacitet
			tilemap_parent.modulate = color


		var tilemap_node = get_parent().get_parent().get_node("Map2")  # byt "TileMap" till rätt namn
		
		if tilemap_node:
			var color = tilemap_node.modulate
			color.a = 1.0  # t.ex. 30% opacitet
			tilemap_node.modulate = color
			
		print(plpower," ",self,"removed",_extra_arg_0)
		emit_signal("doormatch", strength)
		queue_free()
	elif body.get_name() == "player" && plpower != strength:
		emit_signal("nomatch", strength)	
