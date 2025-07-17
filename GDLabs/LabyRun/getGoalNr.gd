extends Label
export var number_of_doors = 9

var current_segment
var doornums = []
var door_nr


func _ready():
	current_segment = 1 # Starting at segment
	for e in range(1,number_of_doors + 1):
		door_nr = get_node("/root/colworld/Map" + str(e)).solution
		doornums.append(door_nr)
		print(door_nr)
		
	text = str(doornums[current_segment - 1])

func next_segment():
	current_segment += 1
	if current_segment >= number_of_doors:
		text = "BOSS"
		return
	text = str(doornums[current_segment - 1])
