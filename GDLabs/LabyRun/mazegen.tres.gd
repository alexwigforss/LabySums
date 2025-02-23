extends TileMap

var _dirs = [-1,1]
var dir = 0

var cellsize = 16.0
var half_cell = 8.0

var start = Vector2(1,13)
var goal = Vector2(12,1)

var shift = Vector2(8,8)

var directions = [['up'],['right'],['down'],['left']]
var possible_steps = [Vector2(0,-1),Vector2(1,0),Vector2(0,1),Vector2(-1,0)]
var probs = ['s']
var route = [start]
var turnpoints = [start]
var freepoints = [start]

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
	var dir = 0
	var current_direction = possible_steps[dir]
	var gofrom = start
	var goto = start + current_direction
	var cango = false
	while true:
		var reversed_direction = Vector2(-current_direction.x, -current_direction.y)
		for e in possible_steps:
			if e == reversed_direction:
				print('wont go back')
				continue
			var lookat = gofrom + e
			if get_cell(lookat.x,lookat.y):
				cango = true
				route.append(lookat)
			else:
				cango = false
			print(e , cango)
		
		if get_cell(goto.x, goto.y) != 0:
			gofrom = goto
			goto = gofrom + current_direction
			route.append(gofrom)
		else:
			dir = (dir + 1) % possible_steps.size()  # Cycle to the next direction
			current_direction = possible_steps[dir]
			goto = gofrom + current_direction
			print('bam wall, direction is now', directions[dir][0])
		# Temporary stopping condition to prevent infinite loops
		if route.size() >= 30:  # Example condition to stop after 10 steps
			break
	print(route)
	
func next_direction(_dir):
	if _dir < 3:
		return _dir + 1
	else:
		return 0


func no_possible_steps(_pos):
	var nps = 0
	for step in possible_steps:
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


func _draw():
	draw_arc((start * 16) + shift, 8.0, 0, 2 * PI, 64, Color.green, 2.0)
	var size = 0.01
	size = 6.0
	var prev_turn_point = turnpoints[0]
	for e in route:
		draw_arc((e * 16) + shift, size, 0, 2 * PI, 64, Color.darkturquoise, 0.5)
		# draw_line((prev_turn_point * 16) + shift, (e * 16) + shift, Color.deeppink , 1.0)
		prev_turn_point = e

func get_dir():
	var random_dir = _dirs[randi() % _dirs.size()]
	return random_dir
