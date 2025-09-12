extends KinematicBody2D

export var speed := 200
export var rotation_speed := 1.5
export var rotation_direction := -1
var velocity := Vector2.ZERO

func _physics_process(delta):
	# Roterar kroppen
	rotation += rotation_direction * rotation_speed * delta

	# Flyttar kroppen i den riktning den pekar
	# velocity = Vector2.RIGHT.rotated(rotation) * speed
	move_and_slide(velocity)
