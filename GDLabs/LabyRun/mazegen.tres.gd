extends TileMap

var _dirs = [-1,1]
var dir = 0
# TODO Clear entrance CLEAR exit
# Skapa en PackedScene av din pickable scen
var pickable_scene: PackedScene = preload("res://scenes/PickOp.tscn")
# Referens till player-objektet
onready var player = get_node("/root/colworld/player")
#onready var player = $player
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
			
	# Metod för att skapa och lägga in pickable scenen
	var pickable_instance = pickable_scene.instance()
	pickOps.add_child(pickable_instance)
	pickable_instance.position = Vector2(20, 120)
	pickable_instance.connect("op_picked", player, "_on_pickOp_op_picked")

func get_dir():
	var random_dir = _dirs[randi() % _dirs.size()]
	return random_dir
