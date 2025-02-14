extends TileMap

var _dirs = [-1,1]
var dir = 0
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
	pass

func get_dir():
	var random_dir = _dirs[randi() % _dirs.size()]
	return random_dir
