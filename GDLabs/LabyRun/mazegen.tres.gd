extends TileMap

var _dirs = [-1,1]
var dir = 0

var start = Vector2(1,13)
var goal = Vector2(12,1)

var shift = Vector2(8,8)
var route = []

var directions = [['down'],['up'],['right'],['left']]
var possible_steps = [Vector2(0,1),Vector2(0,-1),Vector2(1,0),Vector2(-1,0)]
var probs = ['s']
var turnpoints = [start]
var freepoints = [start]

# TODO CLEAR entrance CLEAR exit

# Skapa en PackedScene av PickOp
var pickable_scene: PackedScene = preload("res://scenes/PickOp.tscn")
# Referens till player-objektet
onready var player = get_node("/root/colworld/player")
onready var pickOps = get_node("pickOps")

func _ready():
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
	
	assemble_route()
			
	# Metod för att skapa och lägga in pickable scenen
	var pickable_instance = pickable_scene.instance()
	pickOps.add_child(pickable_instance)
	pickable_instance.position = Vector2(20, 120)
	pickable_instance.connect("op_picked", player, "_on_pickOp_op_picked")

func assemble_route():
	var assemblin = true
	var i = 0
	var _pos = start
	var prev = Vector2()
	while _pos != goal:
		var _pdirect = []
		for step in possible_steps:
			if prev == _pos + step:
				pass
			elif get_cell(_pos.x + step.x,_pos.y + step.y) != 0:
				_pdirect.append(_pos + step)
		var nP = len(_pdirect)
		prev = _pos
		if nP == 1:
			_pos = _pdirect[0]
		elif nP > 1:
			turnpoints.append(_pos)
			var random_index = randi() % _pdirect.size()
			var random_element = _pdirect[random_index]
			_pos = random_element
		freepoints.append(_pos)
		i+=1
		if i > 200:
			break
	print('Length of freepoints = ', len(freepoints))

func _draw():
	draw_arc((start * 16) + shift, 8.0, 0, 2 * PI, 64, Color.aquamarine, 2.0)
	var size = 0.01
#	for e in freepoints:
#		draw_arc((e * 16) + shift, size, 0, 2 * PI, 64, Color.deeppink, 0.5)
#		size += 0.01
	size = 6.0
	var prev_turn_point = turnpoints[0]
	for e in turnpoints:
		draw_arc((e * 16) + shift, size, 0, 2 * PI, 64, Color.darkturquoise, 0.5)
		draw_line((prev_turn_point * 16) + shift, (e * 16) + shift, Color.deeppink , 1.0)
		prev_turn_point = e

func get_dir():
	var random_dir = _dirs[randi() % _dirs.size()]
	return random_dir
