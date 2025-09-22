extends KinematicBody2D
var prepos = Vector2.ZERO

# The actual start position for reseting
var start_position: Vector2
export var speed = 20.0
# The startposition quantified to the grid
export var start_pos_ind = Vector2(1,1)
var pos_ind = start_pos_ind
export var debug_print = false
export var move = true
export var static = true

var velocity := Vector2.ZERO
onready var segment = get_node("../..")
var inner_dim = 13
var direction
var pause_count := 1.0
var pause_time := 0.1

var step_count = 0
var frame_count = 0

var index = 0
export var directions = ['down','right','up','left']
export var steps = [0,0,0,0]

var direction_labels = ['down','right','up','left']
var steps_index = steps [index]

var first_frame = true

# --- SIGNALS ---
signal player_hit


func _ready():
	my_init()
	add_to_group("enemies")


func my_init():
	velocity = Vector2.ZERO
	pos_ind = start_pos_ind
	position = Vector2(pos_ind.x * 16, pos_ind.y * 16)  # consistent ordering
	
	# snap to exact grid in case of float drift
	position.x = round(position.x)
	position.y = round(position.y)
	
	start_position = position
	index = 0
	if static:
		steps_index = steps[index]
		change_direction(directions[index])
	
	pause_count = 0.0



func look_around(pos: Vector2):
	var availible_directions = []
	var v_dirs = [Vector2(0,1), Vector2(1,0), Vector2(0,-1), Vector2(-1,0)] # down, right, up, left
	for i in range(v_dirs.size()):
		var new_y = pos.y + v_dirs[i].y
		var new_x = pos.x + v_dirs[i].x
		if look_at_tile(new_y, new_x) > -1:
			availible_directions.append(direction_labels[i])
	return availible_directions


# Look ahead in curent direction until path is straight and not dead end
# thr Threshold
func look_ahead(dir,pos):#mby dir shold be a direction vector
	var i = 0
	var done = false
	var l_num = 0
	var ahead_string = ""
	while not done:
		if dir == 'down':
			l_num = look_at_tile(pos.y+i,pos.x) 
		elif dir == 'right':
			l_num = look_at_tile(pos.y,pos.x + i) 
		elif dir =='up':
			l_num = look_at_tile(pos.y-i,pos.x)
		elif dir =='left':
			l_num = look_at_tile(pos.y,pos.x - i)
		if l_num > -1:
			i += 1
			ahead_string += str(l_num)
			if i > 1 and l_num > 2:
				print("Found Four-Way: ", ahead_string, " Returning: ", i - 1)			
				done = true
		else:
			done = true
	print("Looked ahead: ", ahead_string, " Returning: ", i - 1)
	return i - 1


func look_at_tile(y,x):
	# print("Looking at: ",y ," ",x , " = ", segment.numerical_map[y][x])
	return segment.numerical_map[y][x]


func _physics_process(delta):

	if pause_count > 0.0:
		pause_count -= delta
		return
	if move:
		velocity = move_and_slide(velocity)

	# Qiuk fix to make shure that numerical map is loaded in scene
	if first_frame and debug_print:

		print("Reference to Numerical Representation:")
		print(segment.numerical_map)


	if first_frame:
		if not static:
			steps_index = 0
			get_random_direction()
			change_direction(direction)
			print("First frame direction is: ", direction)

		first_frame = false

	if not first_frame and static and move:
		match direction:
			"down":
				if position.y >= (pos_ind.y + steps_index) * 16:
					get_next_direction()
					change_direction(direction)
			"right":
				if position.x >= (pos_ind.x + steps_index) * 16:
					get_next_direction()
					change_direction(direction)
			"up":
				if position.y <= (pos_ind.y - steps_index) * 16:
					get_next_direction()
					change_direction(direction)
			"left":
				if position.x <= (pos_ind.x - steps_index) * 16:
					get_next_direction()
					change_direction(direction)

	if not first_frame and not static and move:
		var tolerance := 0.5  # eller 1.0 om du vill vara extra säker

		match direction:
			"down":
				if position.y >= (pos_ind.y + steps_index) * 16 - tolerance:
					get_random_direction()
					change_direction(direction)
			"right":
				if position.x >= (pos_ind.x + steps_index) * 16 - tolerance:
					get_random_direction()
					change_direction(direction)
			"up":
				if position.y <= (pos_ind.y - steps_index) * 16 + tolerance:
					get_random_direction()
					change_direction(direction)
			"left":
				if position.x <= (pos_ind.x - steps_index) * 16 + tolerance:
					get_random_direction()
					change_direction(direction)
		#print("STEP: ", step_count, " FRAME: ", frame_count, " DIRECTION: ", direction, " POS_IND: ", pos_ind, " STEPS INDEX: " , steps_index)
		frame_count += 1



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
	step_count += 1


func get_random_direction():
	# DEBUG GOING FROM AND GOING TO
	print("Startpos WAS: ", pos_ind)
	pos_ind.y = round(position.y / 16)
	pos_ind.x = round(position.x / 16)
	print("Startpos IS: ", pos_ind)
	var available = look_around(pos_ind)
	var no_available = len(available)

	randomize()
	direction = available[randi() % no_available]
	print(no_available, " Available directions: ", available, " Chosed: ", direction)

	steps_index = look_ahead(direction, pos_ind)
	print("STEP_INDEX: ", steps_index)
		
	if debug_print:
		print("Got direction ", index, " ", direction)


func get_next_direction():
	index += 1
	if index >= len(directions):
		index = 0
	direction = directions[index]
	steps_index = steps[index]
	
	pos_ind.y = round(position.y / 16)
	pos_ind.x = round(position.x / 16)
	
	if debug_print:
		print("New Startpos set: ", pos_ind, " Got direction ", index, " ", direction)

func reset_to_start() -> void:
	my_init()
	position.x = round(position.x)
	position.y = round(position.y)
	
	if not static:
		steps_index = 0
		get_random_direction()
		change_direction(direction)


func _on_Area2D_body_entered(body) -> void:
	if body.is_in_group("player"):
		if debug_print:
			print("Player hit by enemy_1 !")
		emit_signal("player_hit")
		reset_to_start()
