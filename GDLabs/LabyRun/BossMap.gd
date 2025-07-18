extends TileMap

var cellsize = 16.0
var half_cell = 8.0

var nums = [1,2,3]
var ops = [0,1,2]
# var nums = [1,2,3,4,5,6,7,8,9,0,1,2,3,4,5,6,7,8,9,0]
# var ops = [0,1,2,3,0,1,2,3,0,1,2,3,0,1,2,3,0,1,2,3]

# Skapa en PackedScene av PickOp
var pickable_op: PackedScene = preload("res://scenes/PickOp.tscn")
# Skapa en PackedScene av PickNum
var pickable_num: PackedScene = preload("res://scenes/PickNum.tscn")

onready var player = get_node("/root/colworld/player")
onready var pickOps = get_node("pickOps")
onready var pickNums = get_node("pickNums")
onready var overLay = get_node("overLay")
# Called when the node enters the scene tree for the first time.
func _ready():
		place_picks()

func place_picks():
	# var depth = 1
	var num = true
	var num_index = 0
	var op_index = 0

	var x = 0
	var y = 2
	var directions = [
		Vector2(2, 0),   # right
		Vector2(0, 2),   # down
		Vector2(-2, 0),  # left
		Vector2(0, -2)   # up
	]
	var steps = [6, 5, 5, 4] # steps for each direction
	var dir_index = 0

	for i in steps:
		for _j in range(i):
			x += int(directions[dir_index].x)
			y += int(directions[dir_index].y)
			if num:
				if num_index < nums.size():
					instance_num(x, y, nums[num_index])
					num_index += 1
					num = false
				if num_index >= nums.size():
					num_index = 0
			else:
				if op_index < ops.size():
					instance_pick(x, y, ops[op_index])
					op_index += 1
					num = true
				if op_index >= ops.size():
					op_index = 0		
			# depth += 1
		dir_index += 1
		

		
func instance_pick(px,py,op):
	px*=16
	py*=16
	var pickable_instance = pickable_op.instance()
	pickable_instance.set_opnr(op)
	pickable_instance.init_boss_picks()
	pickOps.call_deferred("add_child", pickable_instance)
	#pickOps.add_child(pickable_instance)
	pickable_instance.position = Vector2(px+half_cell, py+half_cell)
	pickable_instance.connect("op_picked", player, "_on_pickOp_op_picked")
	pickable_instance.connect("op_picked_boss", self, "_on_pickOp_op_picked")

func instance_pick_at(px,py,op):
	# px*=16
	#py*=16
	var pickable_instance = pickable_op.instance()
	pickable_instance.set_opnr(op)
	pickable_instance.init_boss_picks()
	pickOps.call_deferred("add_child", pickable_instance)
	#pickOps.add_child(pickable_instance)
	pickable_instance.position = Vector2(px+half_cell, py+half_cell)
	pickable_instance.connect("op_picked", player, "_on_pickOp_op_picked")
	pickable_instance.connect("op_picked_boss", self, "_on_pickOp_op_picked")

func _on_pickOp_op_picked(x,y,opnr):
	print("Operator picked:", opnr)
	yield(get_tree().create_timer(1.5), "timeout") # 0.5 second delay
	print("Delayed output", x ," " ,  y , " " , opnr)
	instance_pick_at(x, y, opnr)

# SUGESTION give the player strength of the first number at entrance of new segment (door opened)
func instance_num(px,py,num):
	px *= 16
	py *= 16
	var num_instance = pickable_num.instance()
	num_instance.init_value(num)
	#pickNums.add_child(num_instance)
	pickNums.call_deferred("add_child", num_instance)
	num_instance.position = Vector2(px+half_cell, py+half_cell)
	num_instance.connect("picked", player, "_on_Area2d_picked")
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
