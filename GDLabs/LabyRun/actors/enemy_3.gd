extends KinematicBody2D

var start_position: Vector2
export var speed: float = 20.0

var velocity: Vector2 = Vector2.ZERO

var stored_x = 0
var stored_y = 0

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

	# Connect signals from sensors
	#$Area2D.connect("body_entered", self, "_on_main_sensor")

	$AreaLeft.connect("body_entered", self, "_on_left_sensor")
	$AreaRight.connect("body_entered", self, "_on_right_sensor")
	$AreaUp.connect("body_entered", self, "_on_up_sensor")
	$AreaDown.connect("body_entered", self, "_on_down_sensor")

func _physics_process(delta: float) -> void:
	# Just move straight in current velocity
	velocity = move_and_slide(velocity)

	#const EPSILON := 0.0001
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

	elif velocity.y == 0 and velocity.x != 0:
		var sign_y = (randi() % 2) * 2 - 1
		velocity.y = sign_y * speed


# --- Sensor handlers ---
func _on_left_sensor(body: Node) -> void:
	if body.is_in_group("walls"):
		velocity.x = abs(velocity.x)  # bounce right

func _on_right_sensor(body: Node) -> void:
	if body.is_in_group("walls"):
		velocity.x = -abs(velocity.x) # bounce left

func _on_up_sensor(body: Node) -> void:
	if body.is_in_group("walls"):
		velocity.y = abs(velocity.y)  # bounce down

func _on_down_sensor(body: Node) -> void:
	if body.is_in_group("walls"):
		velocity.y = -abs(velocity.y) # bounce up

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
