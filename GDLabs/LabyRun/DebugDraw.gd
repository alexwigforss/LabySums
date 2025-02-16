extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
func _draw():
	draw_rect(Rect2(1.0, 1.0, 3.0, 3.0), Color.aliceblue)
	draw_rect(Rect2(5.5, 1.5, 2.0, 2.0), Color.aliceblue, false, 1.0)
	draw_rect(Rect2(9.0, 1.0, 5.0, 5.0), Color.aliceblue)
	draw_rect(Rect2(16.0, 2.0, 3.0, 3.0), Color.aliceblue, false, 2.0)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
