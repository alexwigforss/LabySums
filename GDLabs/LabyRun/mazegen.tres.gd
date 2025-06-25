extends TileMap

# ['0','1','2','3']

export var start_dir = 0
export var debug_print_init = false
export var debug_print_route = false
export var debug_draw_routes = false
export var verbose = false
export var random_maze = true
export var start = Vector2(1,13)
export var goal = Vector2(12,1)
export var number_of_operators = 1
export var result_max = 20

var signs = ['+','-','*','/']
var shift = Vector2(8,8)
var direction_labels = [['up'],['right'],['down'],['left']]
var directions = [Vector2(0,-1),Vector2(1,0),Vector2(0,1),Vector2(-1,0)]
var start_directions = [directions[start_dir]]
var start_directions_int = [start_dir]
var probs = ['s']
var route = [start]
var routes = [route]
var nums = [6,2,2,3]
var ops = [0,1,2]
var _dirs = [-1,1]
var cellsize = 16.0
var half_cell = 8.0


# Skapa en PackedScene av PickOp
var pickable_scene: PackedScene = preload("res://scenes/PickOp.tscn")
# Skapa en PackedScene av PickOp
var pickable_num: PackedScene = preload("res://scenes/PickNum.tscn")


# Referenser
onready var player = get_node("/root/colworld/player")
onready var pickOps = get_node("pickOps")
onready var pickNums = get_node("pickNums")

var solution = 9999999


func get_expression(n,o):
	var x = []
	var i = 0
	for e in n:
		x.append(e)
		if i < len(n) - 1:
			x.append(signs[o[i]])
			i += 1
	return x


func get_expression_string(n,o):
	var s = ""
	var i = 0
	for e in n:
		s += str(e) + " "
		if i < len(n) - 1:
			s += str(signs[o[i]]) + " "
			i += 1
	return s


func _ready():
	var csharp_node = get_node("../TaskFactory")
	var door_node = get_node("door")
	# var result = csharp_node.AddNumbers(3, 5)
	while solution > result_max:	
		csharp_node.createExpression(number_of_operators);
		nums = csharp_node.getNums();
		ops = csharp_node.getSigns();
		solution = csharp_node.getSolution();
		if debug_print_init:
			print("Debug print from: ", self)
			var expression = get_expression_string(nums,ops)
			print("Generated expression: " ,expression ," = " , solution)

	

	door_node.set_streangth(solution);

	# print("Nums är: ", nums)
	# print("Digs är: ", digs)
	# print("Signs är: ", ops)

	random_maze() if random_maze else no_random_maze()
	assemble_route(-1,0)
	#print(routes[0])
	var temp_dir = start_directions_int[1]
	#assemble_route(temp_dir,1)
	var i = 1
	#while i < len(routes):
	while i < 20:
	# TODO Add Exception Handling
	#while i < start_directions_int.size():
		# print("Start Directions Int Size: ", start_directions_int.size())
		assemble_route(start_directions_int[i],i)
		i += 1
		
	routes = pop_sublists_with_length_one(routes)
	
	# TODO Fixa buggen att routes ibland inte räcker till för att rita ut all num och ops
	# Kanske genom att söka från ett annat hörn ifall listan är för liten

	# DIBOOGIENG
	if debug_print_route:
		print("Start direction is ", start_dir, " ", direction_labels[start_dir])
		print("Direction Vectors: ")
		print(start_directions)
		print("Direction Ints:")
		print(start_directions_int)
		if verbose:
			print("Verbose output of all routes:")
			for r in routes:
				print(r)

	random_picks()

func random_picks():
	var depth = 1
	var num = true
	var num_index = 0
	var op_index = 0
	# BUG Alla ritas inte alltid ut
	# FÖRSLAG förbättra, assemble_route
	# eller itterera över alla tal och börja om
	# ELLER Radbryt Routes oftare
	while depth < len(routes):
		var x = routes[depth][int(routes[depth].size()/3)].x
		var y = routes[depth][int(routes[depth].size()/3)].y
	
		if num:
			if num_index < nums.size():
				instance_num(x, y, nums[num_index])
				num_index += 1
				num = false
		else:
			if op_index < ops.size():
				instance_pick(x, y, ops[op_index])
				op_index += 1
				num = true
		depth += 1
		

func instance_pick(px,py,op):
	px*=16
	py*=16
	var pickable_instance = pickable_scene.instance()
	pickable_instance.set_opnr(op)
	pickOps.add_child(pickable_instance)
	pickable_instance.position = Vector2(px+half_cell, py+half_cell)
	pickable_instance.connect("op_picked", player, "_on_pickOp_op_picked")

# SUGESTION give the player strength of the first number
# At segment enter
func instance_num(px,py,num):
	px *= 16
	py *= 16
	var num_instance = pickable_num.instance()
	num_instance.init_value(num)
	pickNums.add_child(num_instance)
	num_instance.position = Vector2(px+half_cell, py+half_cell)
	num_instance.connect("picked", player, "_on_Area2d_picked")

# Function to pop sublists with length 1
func pop_sublists_with_length_one(lists):
	var new_list = []
	for sublist in lists:
		if sublist.size() != 1:
			new_list.append(sublist)
	return new_list

func look(pos, gofrom, d):
	if not get_cell(gofrom.x + directions[pos].x, gofrom.y  + directions[pos].y) in [0, 1]:
		if not gofrom + directions[pos] in routes[0]:
			routes += [[gofrom + directions[pos]]]
			start_directions.append(directions[pos])
			start_directions_int.append(d)
			return true

func is_pos_pressent(pos):
	for route in routes:
		if pos in route:
			return true
	return false
	
func assemble_route(dir,rout_index):
	var current_direction = directions[dir]
	start = routes[rout_index][0]
	var gofrom = start
	var goto = start + current_direction
	var index = 0
	#print(routes)
	var foundSplit = false
	var assemblin = true
	#print('Start direcction: ', directions[dir] )
	
	#var turned = false
	while assemblin:
		# OM NÄSTA STEG ÄR VÄGG
		if get_cell(goto.x, goto.y) in [0,1]:
			dir = (dir + 1) % 4 # BYT RIKTNING
			current_direction = directions[dir]
			goto = gofrom + current_direction
			# Lock back after first turn in case of split
			if not get_cell(goto.x, goto.y) in [0,1]:
				var lookback = (dir - 2) % 4
				look(lookback, gofrom,(dir - 2) % 4)
			if get_cell(goto.x, goto.y) in [0, 1]:
				dir = (dir - 2) % 4
				current_direction = directions[dir]
				goto = gofrom + current_direction
		
		if not get_cell(goto.x, goto.y) in [0, 1]:
			# Kollar vänster
			var turnleft = (dir - 1) % 4
			if look(turnleft,gofrom,(dir - 1) % 4):
				pass
				#foundSplit = true
			# Kollar höger
			var turnright = (dir + 1) % 4
			if look(turnright,gofrom,(dir + 1) % 4):
				foundSplit = true

			# UPDATE GOFROM (Ta ett steg)
			gofrom = goto
			goto = gofrom + current_direction
			if is_pos_pressent(gofrom): # Om positionen redan lagrad
				#print('Breaking because of hit SELF_OR_OTHER!')
				break # BRYT
			elif gofrom == goal:
				#print('Breaking because of REACHING_GOAL!')
				break
			#elif foundSplit:
			#	routes += [[gofrom]]
			#	start_directions.append(dir)
			#	start_directions_int.append(dir)
			#	break
			routes[rout_index].append(gofrom)

		index += 1
		if index >= 40:
			#print('Breaking because of INDEX!')
			#assemblin = false
			break
			
	#print('GOFROM',gofrom,'GOTO',goto,'Direction: ',directions[dir])
	#print(len(routes))
	current_direction = directions[dir]	


func _draw():
	if debug_draw_routes:
		# draw_arc((start * 16) + shift, 8.0, 0, 2 * PI, 64, Color.green, 2.0)
		var size = 6.0
	
		# Define an array of colors to use for different routes
		var colors = [Color.cyan, Color.magenta, Color.yellow, Color.orange, Color.purple, Color.red, Color.blue, Color.pink, Color.cornsilk, Color.darkblue]
		var color_count = colors.size()
	
		# Loop through all routes and draw them with different colors
		for route_index in range(routes.size()):
		#for route_index in range(0,3):
			var color = colors[route_index % color_count]
			for e in routes[route_index]:
			#var e = routes[route_index][0]
				draw_arc((e * 16) + shift, size, 0, 2 * PI, 64, color, 0.5)


func next_direction(_dir):
	if _dir < 3:
		return _dir + 1
	else:
		return 0

func no_possible_steps(_pos):
	var nps = 0
	for step in directions:
		if not get_cell(_pos.x + step.x,_pos.y + step.y) in [0, 1]:
			nps += 1
	return nps


func random_picks_old():
	var num = false
	for x in range(3,12,2):
		for y in range(3,12,2):
			if !num:
				instance_pick(x,y,0)
				num = true
			else:
				instance_num(x,y,4)
				num = false


func no_random_maze():
	return


func random_maze():
	var rx = 0
	var ry = 0
	for x in range(2,13,2):
		for y in range(2,13,2):
			if get_dir() == -1:
				rx = get_dir()
				ry = 0
			else:
				rx = 0
				ry = get_dir()
			set_cell(x+rx,y+ry,0)
	#erase_cell() 
	set_cell(goal.x,goal.y,-1)
	set_cell(start.x,start.y,-1)


func get_dir():
	var random_dir = _dirs[randi() % _dirs.size()]
	return random_dir

