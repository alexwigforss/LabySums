extends TileMap

var cellsize = 16.0
var half_cell = 8.0

var nums = [6,2,2,3]
var ops = [0,1,2]

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
		random_picks()

func random_picks():
	var depth = 1
	var num = true
	var num_index = 0
	var op_index = 0

	var x = 0
	var y = 0

	while depth < 8:
		x += 1
		y += 1
	
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
	var pickable_instance = pickable_op.instance()
	pickable_instance.set_opnr(op)
	pickOps.call_deferred("add_child", pickable_instance)
	#pickOps.add_child(pickable_instance)
	pickable_instance.position = Vector2(px+half_cell, py+half_cell)
	pickable_instance.connect("op_picked", player, "_on_pickOp_op_picked")


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
