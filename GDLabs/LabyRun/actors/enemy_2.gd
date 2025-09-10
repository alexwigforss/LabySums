extends KinematicBody2D
var start_position: Vector2
# Editable speed
export var speed := 40.0
# Current velocity (diagonal at 45°)
var velocity := Vector2.ZERO
onready var segment = get_node("../..")
var inner_dim = 13
var steps = 3
var grid_x = 1
var grid_y = 1
var direction = "down"
var pause_count := 0.0
var pause_time := 1.0

# TODO this is for the smartness and is intended to be trained with the goal to get as close as posible to the player.
# 0 = down, 1 = right, 2 = up, 3 = left
var strategy = ['','','','','','',]

# --- SIGNALS ---
signal player_hit


func _ready():
	_init()
	#print(segment.numerical_map)

func _init():
	velocity = Vector2.ZERO
	position = Vector2(16, 16)
	start_position = position
	velocity.y = 1
	velocity.x = 0
	velocity = velocity.normalized() * speed
	grid_x = 1
	grid_y = 1
	direction = "down"
	pause_count = 0.0

func change_direction(new_direction: String, new_velocity: Vector2) -> void:
	direction = new_direction
	velocity = new_velocity.normalized() * speed
	pause_count = pause_time


func _physics_process(delta):
	if pause_count > 0.0:
		pause_count -= delta
		return
	
	match direction:
		"down":
			if position.y >= 7 * 16:
				change_direction("right", Vector2(1, 0))
		"right":
			if position.x >= 5 * 16:
				change_direction("left", Vector2(-1, 0))
		"left":
			if position.x <= 1 * 16:
				change_direction("up", Vector2(0, -1))
		"up":
			if position.y <= 1 * 16:
				change_direction("down", Vector2(0, 1))
	
	move_and_slide(velocity)
	# velocity = move_and_slide(velocity)
	grid_y = round(position.y / 16)
	grid_x = round(position.x / 16)
	print("Position_y: ", position.y, " Step_Y:", grid_y, " Is over: ", segment.numerical_map[grid_y][grid_x])


func count_steps_to_next_turn(direction):
	pass


func reset_to_start() -> void:
	_init()


func _on_Area2D_body_entered(body) -> void:
	if body.is_in_group("player"):
		print("Player hit by enemy_1 !")
		emit_signal("player_hit")
		reset_to_start()
