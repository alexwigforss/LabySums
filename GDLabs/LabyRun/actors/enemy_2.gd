extends KinematicBody2D

# Editable speed
export var speed := 70.0
var timer = 1
# Current velocity (diagonal at 45°)
var velocity := Vector2.ZERO

func _ready():
	randomize()
	# Choose one of the four diagonal directions at 45°
	var directions = [
		Vector2(1, 1),
		Vector2(-1, 1),
		Vector2(1, -1),
		Vector2(-1, -1)
	]
	velocity = directions[randi() % directions.size()].normalized() * speed

func _physics_process(delta):
		var collision = move_and_collide(velocity * delta)
		if collision:
			velocity = velocity.bounce(collision.normal).normalized() * speed
			# Nudge out of the collider
			translate(collision.normal * 0.1)
