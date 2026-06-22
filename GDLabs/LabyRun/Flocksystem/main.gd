extends Node2D

const FLOCK_SIZE = 100

# Ladda in din Flocker-scen här (se till att sökvägen stämmer)
var flocker_scene = preload("res://Flocksystem/Flocker.tscn")
onready var target_node = $Pos

func _ready():
	# Godots motsvarighet till setup()
	randomize() # Initierar slumpgeneratorn
	
	# Sätt framerate, helskärm och göm musen
	Engine.target_fps = 32
	# OS.window_fullscreen = true
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	
	# Skapa flocken
	for i in range(FLOCK_SIZE):
		var f = flocker_scene.instance()
		add_child(f)
		f.target_node = target_node

func _process(_delta):
	# Tvingar Godot att rita om (kallar på _draw) varje frame
	update()

func _draw():
	# Motsvarar circle(mouseX, mouseY, 20)
	# Observera att Godots draw_circle tar radie (10), inte diameter (20)
	if target_node:
		draw_circle(target_node.global_position, 10.0, Color.white)
	else:
		var mouse_pos = get_global_mouse_position()
		draw_circle(mouse_pos, 10.0, Color.white)
