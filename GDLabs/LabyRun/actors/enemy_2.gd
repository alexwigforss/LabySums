# TODOS
# [ ] Start Random
# [ ] Assemble Strategy
# [ ] Reward / Punish

extends KinematicBody2D
var start_position: Vector2

# Editable speed
export var speed := 40.0
export var debug_print = false



var velocity := Vector2.ZERO
onready var segment = get_node("../..")
var inner_dim = 13
var direction
var pause_count := 0.0
var pause_time := 1.0

var index = 0
var start_pos := Vector2(3,3)
var directions = ['down','right','up','left']
var steps = [2,2,2,2]
var steps_index = steps [index]
# --- SIGNALS ---
signal player_hit


func _ready():
	_init()
	add_to_group("enemies")
	#print(segment.numerical_map)

func _init():
	velocity = Vector2.ZERO
	position = Vector2(start_pos.y * 16, start_pos.x * 16)
	start_position = position
	change_direction(directions[index])
	velocity = velocity.normalized() * speed
	direction = directions[index]
	pause_count = 0.0

func change_direction(new_direction: String) -> void:
	var new_velocity = Vector2.ZERO
	direction = new_direction

	match direction:
		"down":
			new_velocity = Vector2(0, 1)
		"right":
			new_velocity = Vector2(1, 0)
		"left":
			new_velocity = Vector2(-1, 0)
		"up":
			new_velocity = Vector2(0, -1)

	
	velocity = new_velocity.normalized() * speed
	pause_count = pause_time


func _physics_process(delta):
	if pause_count > 0.0:
		pause_count -= delta
		return
	
	match direction:
		"down":
			if position.y >= (start_pos.y + steps_index) * 16:
				get_next_direction()
				change_direction(direction)
		"right":
			if position.x >= (start_pos.x + steps_index) * 16:
				get_next_direction()
				change_direction(direction)
		"left":
			if position.x <= (start_pos.x - steps_index) * 16:
				get_next_direction()
				change_direction(direction)
		"up":
			if position.y <= (start_pos.y - steps_index) * 16:
				get_next_direction()
				change_direction(direction)
	# print("Y : ", round(position.y / 16),"  X: ", round(position.x / 16))
	
	velocity = move_and_slide(velocity)


func get_next_direction():
	index += 1
	if index >= len(directions):
		index = 0
	direction = directions[index]
	steps_index = steps[index]
	
	start_pos.y = round(position.y / 16)
	start_pos.x = round(position.x / 16)
	
	if debug_print:
		print("Got direction ", index, " ", direction)

func reset_to_start() -> void:
	_init()

func _on_Area2D_body_entered(body) -> void:
	if body.is_in_group("player"):
		if debug_print:
			print("Player hit by enemy_1 !")
		emit_signal("player_hit")
		reset_to_start()
