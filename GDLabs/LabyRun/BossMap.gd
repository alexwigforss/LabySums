extends TileMap


var cellsize = 16.0
var half_cell = 8.0

# NOTE If we want a zero here we need to excepthandle div by 0
var nums = [1,2,3,4,5,6,7,8,9,0,1,2,3,4,5,6,7,8,9]
var ops = [0,1,2,3]

var pickable_op: PackedScene = preload("res://scenes/PickOp.tscn")
var pickable_num: PackedScene = preload("res://scenes/PickNum.tscn")

onready var player = get_node("/root/colworld/player")
onready var pickOps = get_node("pickOps")
onready var pickNums = get_node("pickNums")
onready var overLay = get_node("overLay")
var start_pos
export var start = Vector2(1,7)

func _ready():
	start_pos = start
	place_picks()

func place_picks():
	var num = true
	var num_index = 0
	var op_index = 0

	var x = 0
	var y = 2
	var directions = [
		Vector2(2, 0),   # rightstep
		Vector2(0, 2),   # downstep
		Vector2(-2, 0),  # leftstep
		Vector2(0, -2)   # upstep
	]
	var steps = [6, 5, 5, 4] # nr of steps for each direction
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
		dir_index += 1

# INSTANCIATING PICKUPS
		
func instance_pick(px, py, op):
	px*=16
	py*=16
	instance_pick_at(px, py, op)


func instance_pick_at(px, py, op):
	var pickable_instance = pickable_op.instance()
	pickable_instance.set_opnr(op)
	pickable_instance.init_boss_picks()
	pickOps.call_deferred("add_child", pickable_instance)
	pickable_instance.position = Vector2(px+half_cell, py+half_cell)
	pickable_instance.connect("op_picked", player, "_on_pickOp_op_picked")
	pickable_instance.connect("op_picked_boss", self, "_on_pickOp_op_picked")


func instance_num(px,py,num):
	px *= 16
	py *= 16
	instance_num_at(px,py,num)


func instance_num_at(px,py,num):
	var num_instance = pickable_num.instance()
	num_instance.init_value(num)
	num_instance.init_boss_picks()
	pickNums.call_deferred("add_child", num_instance)
	num_instance.position = Vector2(px+half_cell, py+half_cell)
	num_instance.connect("picked", player, "_on_Area2d_picked")
	num_instance.connect("num_picked_boss", self, "_on_pickNum_picked")

# SIGNALING RECIEVERS

var active_timers = []

func _on_pickOp_op_picked(x, y, opnr):
	print("Operator picked:", opnr)
	var timer = Timer.new()
	timer.wait_time = 3
	timer.one_shot = true
	add_child(timer)
	active_timers.append(timer)
	timer.start()
	yield(timer, "timeout")
	active_timers.erase(timer)
	timer.queue_free()
	print("Delayed output", x, y, opnr)
	instance_pick_at(x-8, y-8, opnr)

func _on_pickNum_picked(x, y, v):
	print("Number picked:", v)
	var timer = Timer.new()
	timer.wait_time = 3
	timer.one_shot = true
	add_child(timer)
	active_timers.append(timer)
	timer.start()
	yield(timer, "timeout")
	active_timers.erase(timer)
	timer.queue_free()
	print("Delayed output", x, y, v)
	instance_num_at(x-8, y-8, v)

func clear_nums_and_ops():
	print("Clear Nums And Ops ", self)
	for timer in active_timers:
		timer.stop()
		timer.queue_free()
	active_timers.clear()

	for child in pickOps.get_children():
		if child is PickOp:
			child.free()

	for child in pickNums.get_children():
		if child is PickNum:
			child.free()
			
	for child in overLay.get_children():
		child.free()

	place_picks()

	for child in pickOps.get_children():
		if child is PickOp:
			print("It's a PickOp:", child)

	for child in pickNums.get_children():
		if child is PickNum:
			print("It's a PickNum:", child)
			
	pickNums.modulate.a = 1
	pickOps.modulate.a = 0.5
