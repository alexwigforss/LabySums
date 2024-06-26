extends TileMap

export var generate_on_ready = true
### funkar bara med udda nummer ###
export var  MAZE_SIZE = Vector2(10,10)
export var  MAZE_POS = Vector2(1, 1)
export var PLAYER_POS = Vector2()
export var PRE_POS = Vector2()
export var WALL_ID = 0
export var PATH_ID = 1
export var LIMIT_ID = 2
export var WIZ_ID = 3

const DIRECTIONS = [
	Vector2.UP * 2,
	Vector2.DOWN * 2,
	Vector2.RIGHT * 2,
	Vector2.LEFT * 2,
]
var current_cell = Vector2.ONE
var visited_cells = [current_cell]
var stack = []
var cells = []

func _ready():
	PRE_POS = Vector2(MAZE_POS.x,MAZE_POS.y)
	PLAYER_POS = Vector2(MAZE_POS.x,MAZE_POS.y)
	current_cell += MAZE_POS - Vector2.ONE
	if generate_on_ready:
		generate_maze()

func _input(event):
	if event.is_action_pressed("ui_accept"):
		generate_maze()
	if event.is_action_pressed("ui_left"):
		PLAYER_POS.x -= 1
		player_move()
	if event.is_action_pressed("ui_up"):
		PLAYER_POS.y -= 1
		player_move()
	if event.is_action_pressed("ui_right"):
		PLAYER_POS.x += 1
		player_move()
	if event.is_action_pressed("ui_down"):
		PLAYER_POS.y += 1
		player_move()

func player_move():
	if get_cell(PLAYER_POS.x,PLAYER_POS.y) == PATH_ID:
		set_cell(PLAYER_POS.x,PLAYER_POS.y,WIZ_ID)
		set_cell(PRE_POS.x,PRE_POS.y,PATH_ID)
		PRE_POS = PLAYER_POS
	else:
		PLAYER_POS = PRE_POS
		
### MAZE GENERATION ###

func generate_maze():
	#Clear the maze
	visited_cells = [current_cell]
	stack.clear()
	# Create walls
	for x in MAZE_SIZE.x:
		for y in MAZE_SIZE.y:
			set_cell(x+MAZE_POS.x, y+MAZE_POS.y, WALL_ID)
	# Create limits
	for x in MAZE_SIZE.x+2:
		set_cell(x+MAZE_POS.x-1, MAZE_POS.y-1, LIMIT_ID)
		set_cell(x+MAZE_POS.x-1, MAZE_POS.y-2, LIMIT_ID)
	for x in MAZE_SIZE.x+2:
		set_cell(x+MAZE_POS.x-1, MAZE_SIZE.y + MAZE_POS.y, LIMIT_ID)
		set_cell(x+MAZE_POS.x-1, MAZE_SIZE.y + MAZE_POS.y+1, LIMIT_ID)
	for y in MAZE_SIZE.y:
		set_cell(MAZE_POS.x-1, MAZE_POS.y + y , LIMIT_ID)
		set_cell(MAZE_POS.x-2, MAZE_POS.y + y , LIMIT_ID)
	for y in MAZE_SIZE.y:
		set_cell(MAZE_SIZE.x + MAZE_POS.x, MAZE_POS.y + y , LIMIT_ID)
		set_cell(MAZE_SIZE.x + MAZE_POS.x+1, MAZE_POS.y + y , LIMIT_ID)
	#create cells
	for x in (MAZE_SIZE.x+1)/2:
		for y in (MAZE_SIZE.y + 1)/2:
			set_cell(MAZE_POS.x + 2 * x , MAZE_POS.y + 2 * y, PATH_ID)
	#get cells
	cells = get_used_cells_by_id(PATH_ID)
	#generate maze
	while visited_cells.size() < cells.size():
		var neighbours = neighbours_have_not_been_visited(current_cell)
		if neighbours.size() > 0:
			var random_neighbour = neighbours[randi()%neighbours.size()]
			stack.push_front(current_cell)
			var wall = (random_neighbour - current_cell)/2 + current_cell
			set_cell(int(wall.x), int(wall.y), 1)
			current_cell = random_neighbour
			visited_cells.append(current_cell)
		elif stack.size() > 0:
			current_cell = stack[0]
			stack.pop_front()
			
	set_cell(PLAYER_POS.x,PLAYER_POS.y,WIZ_ID)

func neighbours_have_not_been_visited(cell):
	var neighbours = []
	for dir in DIRECTIONS:
		if not visited_cells.has(cell + dir) and get_cell(int(cell.x + dir.x), int(cell.y + dir.y)) != LIMIT_ID:
			neighbours.append(cell + dir)
	return neighbours
