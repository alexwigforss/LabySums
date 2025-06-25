extends Label


var current_segment
var doornums = []
var door_nr


func _ready():
	current_segment = 1
	for e in range(1,10):
		door_nr = get_node("/root/colworld/Map" + str(e)).solution
		doornums.append(door_nr)
		# print(door_nr)
		
	text = str(doornums[current_segment - 1])

func next_segment():
	current_segment += 1
	text = str(doornums[current_segment - 1])
