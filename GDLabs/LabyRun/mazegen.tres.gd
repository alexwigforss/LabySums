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
var probs = ['s']
var route = [start]
var routes = [route]
# var turnpoints = [start]
# var freepoints = [start]

var nums = [6,2,2]
var ops = ['+','-','*']

# TODO CLEAR entrance CLEAR exit

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
	# random_picks()
	assemble_route()

func assemble_route():
	var dir = -1
	var current_direction = directions[dir]
	var gofrom = start
	var goto = start + current_direction
	var cango = false
	var index = 0
	var newroute = []
	print(routes)
	var assemblin = true
	print('Start direcction: ', directions[dir] )
	var start_directions = [directions[dir]]
	#var turned = false
	while assemblin:

		# Sedan tittar vi rakt fram och om det inte är en vägg
		if get_cell(goto.x, goto.y) == 0:
			dir = (dir + 1) % 4
			current_direction = directions[dir]
			#print('Direction is now: ',dir, directions[dir])
			goto = gofrom + current_direction
			#turned = true
			#if get_cell(goto.x, goto.y) != 0:
				#routes += [[gofrom]]
		
		# Kan vi gå över
		elif get_cell(goto.x, goto.y) != 0:
			#if not turned:
			# Först så titta vi åt vänster
			var turnleft = (dir - 1) % 4
			if get_cell(gofrom.x + directions[turnleft].x, gofrom.y  + directions[turnleft].y) != 0:
				if not gofrom + directions[turnleft] in routes[0]:
					routes += [[gofrom + directions[turnleft]]]
					start_directions.append(directions[turnleft])
			# Sedan tittar vi åt höger
			var turnright = (dir + 1) % 4
			if get_cell(gofrom.x + directions[turnright].x, gofrom.y  + directions[turnright].y) != 0:
				if not gofrom + directions[turnright] in routes[0]:
					routes += [[gofrom + directions[turnright]]]
					start_directions.append(directions[turnright])
			#turned = false


			# UPDATE GOFROM
			gofrom = goto
			goto = gofrom + current_direction
			if not gofrom in routes[0]:
				routes[0].append(gofrom)
			else:
				print('Breaking because of hit self!')
				break

		index += 1
		if index >= 20:
			print('Breaking because of index!')
			#assemblin = false
			break
			
	
	print('GOFROM',gofrom,'GOTO',goto,'Direction: ',directions[dir])
	# dir = (dir + 1) % 4
	current_direction = directions[dir]
	print('GOFROM',gofrom,'GOTO',goto,'Direction: ',directions[dir])
	
	for route in routes:
		print(route)
	print(start_directions)
	print(len(routes))


func _draw():
	# draw_arc((start * 16) + shift, 8.0, 0, 2 * PI, 64, Color.green, 2.0)
	var size = 6.0
	
	# Define an array of colors to use for different routes
	var colors = [Color.cyan, Color.magenta, Color.yellow, Color.orange, Color.purple, Color.red, Color.blue]
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
			

func random_picks():
	var num = false
	for x in range(3,12,2):
		for y in range(3,12,2):
			if !num:
				instance_pick(x,y,x)
				num = true
			else:
				instance_num(x,y)
				num = false

func instance_pick(px,py,s):
	px*=16
	py*=16
	
	# Metod för att skapa och lägga in pickable scenen
	var pickable_instance = pickable_scene.instance()
	pickOps.add_child(pickable_instance)
	pickable_instance.position = Vector2(px+half_cell, py+half_cell)
	pickable_instance.connect("op_picked", player, "_on_pickOp_op_picked")

func instance_num(px,py):
	px *= 16
	py *= 16
	var num_instance = pickable_num.instance()
	num_instance.init_value(4)  # Initialize the value using the init method	num_instance.connect("picked", pickNums, "_on_pickNum_body_entered")
	pickNums.add_child(num_instance)
	num_instance.position = Vector2(px+half_cell, py+half_cell)
	num_instance.connect("picked", player, "_on_Area2d_picked")

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
