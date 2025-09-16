extends KinematicBody2D

# The actual start position for reseting
var start_position: Vector2
export var speed = 20.0
# The startposition quantified to the grid
export var start_pos_ind = Vector2(1,1)
export var debug_print = false

var velocity := Vector2.ZERO
onready var segment = get_node("../..")
var inner_dim = 13
var direction
var pause_count := 0.0
var pause_time := 1.0

var index = 0
var position_index
var directions = ['down','right','up','left']

var direction_labels = ['down','right','up','left']
var direction_nums = [1, 1, -1, -1]
var steps = [6,6,6,6]
var steps_index = steps [index]

var first_frame = true
# --- SIGNALS ---
signal player_hit


func _ready():
	my_init()
	add_to_group("enemies")
	#print(segment.numerical_map)

# _init() is used implicit in _ready()
func my_init():
	start_position = position
	velocity = Vector2.ZERO
	position = Vector2(start_pos_ind.y * 16, start_pos_ind.x * 16)
	position_index = Vector2(start_pos_ind.y, start_pos_ind.x)
	# start_position = position
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

func look_ahead(dir,pos):
	pass

func look_at_tile(y,x):
	return segment.numerical_map[y][x]

func _physics_process(delta):
	if pause_count > 0.0:
		pause_count -= delta
		return
	
	velocity = move_and_slide(velocity)
	match direction:
		"down":
			if position.y >= (start_pos_ind.y + steps_index) * 16:
				get_next_direction()
				change_direction(direction)
		"right":
			if position.x >= (start_pos_ind.x + steps_index) * 16:
				get_next_direction()
				change_direction(direction)
		"up":
			if position.y <= (start_pos_ind.y - steps_index) * 16:
				get_next_direction()
				change_direction(direction)
		"left":
			if position.x <= (start_pos_ind.x - steps_index) * 16:
				get_next_direction()
				change_direction(direction)
	# print("Y : ", round(position.y / 16),"  X: ", round(position.x / 16))	
	if first_frame:
		print("At tile 0,0 number is: ", look_at_tile(0,0))
		print("At tile 1,1 number is: ", look_at_tile(1,1))
		print("At tile 2,2 number is: ", look_at_tile(2,2))
		print("At tile 3,3 number is: ", look_at_tile(3,3))
		print("StartPos = ", start_pos_ind)
		
		first_frame = false


func get_next_direction():
	index += 1
	if index >= len(directions):
		index = 0
	direction = directions[index]
	steps_index = steps[index]
	
	start_pos_ind.y = round(position.y / 16)
	start_pos_ind.x = round(position.x / 16)
	
	if debug_print:
		print("New Startpos set: ", start_pos_ind)
		print("Got direction ", index, " ", direction)

func reset_to_start() -> void:
	my_init()

func _on_Area2D_body_entered(body) -> void:
	if body.is_in_group("player"):
		if debug_print:
			print("Player hit by enemy_1 !")
		emit_signal("player_hit")
		reset_to_start()
