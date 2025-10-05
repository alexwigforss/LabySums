extends KinematicBody2D

var start_position: Vector2
export var speed: float = 20.0

var velocity: Vector2 = Vector2.ZERO

var stored_x = 0
var stored_y = 0

var turned_left = false
var turned_right = true

signal player_hit

var dirs = [
	Vector2(1, 1),
	Vector2(-1, 1),
	Vector2(1, -1),
	Vector2(-1, -1)
]

func _ready() -> void:
	add_to_group("enemies")
	start_position = position
	randomize()
	# Start in one of four diagonal directions
	velocity = dirs[randi() % dirs.size()].normalized() * speed

	$AnimationPlayer.play("walkleft")
	print("HEJ PÅ DIG")

func _physics_process(delta: float) -> void:
	# Just move straight in current velocity
	velocity = move_and_slide(velocity)

	# Ensure constant speed
	if velocity.length() != 0:
		velocity = velocity.normalized() * speed
		
	if velocity.x == 0 and velocity.y == 0:
		print("STANDING")
		velocity = dirs[randi() % dirs.size()].normalized() * speed
	# --- safeguard: force diagonal motion ---
	elif velocity.x == 0 and velocity.y != 0:
		var sign_x = (randi() % 2) * 2 - 1  # yields -1 or +1
		velocity.x = sign_x * speed
		if turned_left and velocity.x > 0:
			$AnimationPlayer.stop()
			$AnimationPlayer.play("walkright")
			turned_left = false
			turned_right = true
		if turned_right and velocity.x < 0:
			$AnimationPlayer.stop()
			$AnimationPlayer.play("walkleft")
			turned_right = false
			turned_left = true


	elif velocity.y == 0 and velocity.x != 0:
		var sign_y = (randi() % 2) * 2 - 1
		velocity.y = sign_y * speed

func _is_actor_like(body: Node) -> bool:
	return body.is_in_group("enemies") and self.name != body.name

func reset_to_start() -> void:
	position = start_position
	velocity = Vector2.ZERO

func _on_Area2D_body_entered(body) -> void:
	if body.is_in_group("player"):
		print("Player hit by enemy_3 !")
		emit_signal("player_hit")
		reset_to_start()
