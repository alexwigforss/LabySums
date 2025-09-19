extends KinematicBody2D

# The actual start position for reseting
var start_position: Vector2
export var speed = 20.0
# The startposition quantified to the grid
export var start_pos_ind = Vector2(1,1)
export var debug_print = false
export var move = true

var velocity := Vector2.ZERO
onready var segment = get_node("../..")
var inner_dim = 13
var direction
var pause_count := 0.0
var pause_time := 1.0

var index = 0
var position_index
export var directions = ['down','right','up','left']
export var steps = [6,6,6,6]

var direction_labels = ['down','right','up','left']
var direction_nums = [1, 1, -1, -1]
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
	velocity = Vector2.ZERO
	position = Vector2(start_pos_ind.y * 16, start_pos_ind.x * 16)
	start_position = position
	position_index = Vector2(start_pos_ind.y, start_pos_ind.x)
	steps_index = steps [index]
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

func look_around(pos):
	var i = 0
	# ['down','right','up','left']
	var availible_directions = [false,false,false,false]
	var v_dirs = [Vector2(1,0),Vector2(0,1),Vector2(-1,0),Vector2(0,-1)]
	for e in v_dirs:
		if look_at_tile(pos.y + e.y,pos.x + e.x) > -1:
			availible_directions[i] = true
		i += 1
	return availible_directions

# Look ahead in curent direction will path is straight and not dead end
func look_ahead(dir,pos):#mby dir hold be a direction vector
	var i = 0
	var done = false
	while not done:
		if dir == 'down':
			if look_at_tile(pos.y+i,pos.x) > -1:
				i += 1
			else:
				done = true
		elif dir == 'right':
			if look_at_tile(pos.y,pos.x + i) > -1:
				i += 1
			else:
				done = true
		elif dir =='up':
			if look_at_tile(pos.y-i,pos.x) > -1:
				i += 1
			else:
				done = true
		elif dir =='left':
			if look_at_tile(pos.y,pos.x - i) > -1:
				i += 1
			else:
				done = true
	return i - 1

func look_at_tile(y,x):
	return segment.numerical_map[y][x]

func _physics_process(delta):
	if pause_count > 0.0:
		pause_count -= delta
		return
	if move:
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
	# Qiuk fix to make shure that numerical map is loaded in scene
	if first_frame and debug_print:

		## Lazy test of look_at
		# print("At tile 0,0 number is: ", look_at_tile(0,0))
		# print("At tile 1,1 number is: ", look_at_tile(1,1))
		# print("At tile 2,2 number is: ", look_at_tile(2,2))
		# print("At tile 3,3 number is: ", look_at_tile(3,3))

		## Lazy test look_ahead
		# print("StartPos = ", start_pos_ind)
		# print(look_ahead("down",start_pos_ind))		
		# print(look_ahead("right",start_pos_ind))		
		# print(look_ahead("up",start_pos_ind))		
		# print(look_ahead("left",start_pos_ind))

		# Lazy test look_around
		print("Available Directions", look_around(start_pos_ind))
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

# Proposal for "Simplifiing" reach check
#
#var direction_data = {
#	"down":  { "axis": "y", "sign":  1 },
#	"up":    { "axis": "y", "sign": -1 },
#	"right": { "axis": "x", "sign":  1 },
#	"left":  { "axis": "x", "sign": -1 },
#}
#
#func check_direction():
#	var data = direction_data[direction]
#	var axis = data.axis
#	var sign = data.sign
#
#	var pos_val = position[axis]
#	var start_val = start_pos_ind[axis]
#	var target = (start_val + sign * steps_index) * 16
#
#	# Compare based on sign
#	if (sign == 1 and pos_val >= target) or (sign == -1 and pos_val <= target):
#		get_next_direction()
#		change_direction(direction)
