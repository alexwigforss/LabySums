extends TileMap

var _dirs = [-1,1]
var dir = 0

var cellsize = 16.0
var half_cell = 8.0

var start = Vector2(1,13)
var goal = Vector2(12,1)

var shift = Vector2(8,8)

var direction_labels = [['up'],['right'],['down'],['left']]
var directions = [Vector2(0,-1),Vector2(1,0),Vector2(0,1),Vector2(-1,0)]
var start_directions = [directions[dir]]
var start_directions_int = [dir]
var probs = ['s']
var route = [start]
var routes = [route]
var nums = [6,2,2]
# ops legend = ['+','-','*','/']
# ops legend = ['0','1','2','3']
var ops = [0,1,2]

# Skapa en PackedScene av PickOp
var pickable_scene: PackedScene = preload("res://scenes/PickOp.tscn")
# Skapa en PackedScene av PickOp
var pickable_num: PackedScene = preload("res://scenes/PickNum.tscn")


# Referens till player-objektet
onready var player = get_node("/root/colworld/player")
onready var pickOps = get_node("pickOps")
onready var pickNums = get_node("pickNums")

func _ready():
	random_maze()
	assemble_route(-1,0)
	print(routes[0])
	var temp_dir = start_directions_int[1]
	#assemble_route(temp_dir,1)
	var i = 1
	#while i < len(routes):
	while i < 15:
		assemble_route(start_directions_int[i],i)
		i += 1
		
	routes = pop_sublists_with_length_one(routes)
	
	# TODO Fixa buggen att routes ibland inte räcker till för att rita ut all num och ops
	# Kanske genom att söka från ett annat hörn ifall listan är för liten
	
	for route in routes:
		print(route)
	print(start_directions)
	print(start_directions_int)

	random_picks()

func random_picks():
	var depth = 1
	var num = true
	var x = 0
	var y = 0
	while depth < len(routes):
		x = routes[depth][int(routes[depth].size()/3)].x
		y = routes[depth][int(routes[depth].size()/3)].y
		if num:
			instance_num(x,y,nums[(depth -1) % nums.size()])
			num = false
		else:
			instance_pick(x,y,ops[(depth -1) % ops.size()])
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
	if get_cell(gofrom.x + directions[pos].x, gofrom.y  + directions[pos].y) != 0:
		if not gofrom + directions[pos] in routes[0]:
			routes += [[gofrom + directions[pos]]]
			start_directions.append(directions[pos])
			start_directions_int.append(d)

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
	var assemblin = true
	print('Start direcction: ', directions[dir] )
	
	#var turned = false
	while assemblin:
		if get_cell(goto.x, goto.y) == 0:
			dir = (dir + 1) % 4
			current_direction = directions[dir]
			goto = gofrom + current_direction
			# Lock back after first turn in case of split
			if get_cell(goto.x, goto.y) != 0:
				var lookback = (dir - 2) % 4
				look(lookback, gofrom,(dir - 2) % 4)
			if get_cell(goto.x, goto.y) == 0:
				dir = (dir - 2) % 4
				current_direction = directions[dir]
				goto = gofrom + current_direction
		
		if get_cell(goto.x, goto.y) != 0:
			# Först så titta vi åt vänster
			var turnleft = (dir - 1) % 4
			look(turnleft,gofrom,(dir - 1) % 4)
			# Sedan tittar vi åt höger
			var turnright = (dir + 1) % 4
			look(turnright,gofrom,(dir + 1) % 4)

			# UPDATE GOFROM (Ta ett stex)
			gofrom = goto
			goto = gofrom + current_direction
			if is_pos_pressent(gofrom):
				print('Breaking because of hit SELF_OR_OTHER!')
				break
			elif gofrom == goal:
				print('Breaking because of REACHING_GOAL!')
				break
			routes[rout_index].append(gofrom)

		index += 1
		if index >= 40:
			print('Breaking because of INDEX!')
			#assemblin = false
			break
			
	
	#print('GOFROM',gofrom,'GOTO',goto,'Direction: ',directions[dir])
	current_direction = directions[dir]
	#print('GOFROM',gofrom,'GOTO',goto,'Direction: ',directions[dir])
	

	#print(len(routes))


func _draw():
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
			draw_arc((e * 16) + shift, size, 0, 2 * PI, 64, color, 0.5)
			
func next_direction(_dir):
	if _dir < 3:
		return _dir + 1
	else:
		return 0


func no_possible_steps(_pos):
	var nps = 0
	for step in directions:
		if get_cell(_pos.x + step.x,_pos.y + step.y) != 0:
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

func get_dir():
	var random_dir = _dirs[randi() % _dirs.size()]
	return random_dir
