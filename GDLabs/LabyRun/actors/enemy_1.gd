extends KinematicBody2D
const GRAVITY = 0.0 # pixels/second/second

# Angle in degrees towards either side that the player can consider "floor"
const FLOOR_ANGLE_TOLERANCE = 40
const WALK_FORCE = 600
const WALK_MIN_SPEED = 10
const WALK_MAX_SPEED = 25
const STOP_FORCE = 1300

const SLIDE_STOP_VELOCITY = 1.0 # one pixel/second
const SLIDE_STOP_MIN_TRAVEL = 1.0 # one pixel

var velocity = Vector2()
var strength = 0
var inertia = 100
var dir = 0
var current_dir = -1
var dir_labels = ['left','up','right','down']
var dirs = [true,false,false,false]
var free_sensors = [true,true,true,true]
signal player_hit
var start_position := Vector2.ZERO
var first_frame = true
var state_has_changed = false
func _ready():
	add_to_group("enemies")
	start_position = position
	
	# TODO Implement on_exited
	$AreaLeft.connect("body_entered", self, "_on_body_entered", ["left",0])
	$AreaUp.connect("body_entered", self, "_on_body_entered", ["up",1])
	$AreaRight.connect("body_entered", self, "_on_body_entered", ["right",2])
	$AreaDown.connect("body_entered", self, "_on_body_entered", ["down",3])

	$AreaLeft.connect("body_exited", self, "_on_body_exited", ["left",0])
	$AreaUp.connect("body_exited", self, "_on_body_exited", ["up",1])
	$AreaRight.connect("body_exited", self, "_on_body_exited", ["right",2])
	$AreaDown.connect("body_exited", self, "_on_body_exited", ["down",3])
	
	
func _on_body_entered(body, direction, index):
	if body.is_in_group("walls") or "Map" in body.name:
		free_sensors[index] = false
		get_node("Area" + direction.capitalize() + "/Highlight").visible = true
		_sight_state_changed(true, index)


func _on_body_exited(body, direction, index):
	if body.is_in_group("walls") or "Map" in body.name:
		free_sensors[index] = true
		get_node("Area" + direction.capitalize() + "/Highlight").visible = false
		print("Exited on", direction, " with ", body.name)
		_sight_state_changed(false, index)


func _sight_state_changed(entered, d_num):
	# print("STATE HAS CHANGED TO ", entered, " ON ", dir_labels[d_num])
	if entered:
		free_sensors[d_num] = false
		return
	elif not entered:
		free_sensors[d_num] = true
		state_has_changed = true
	

func _next_direction_from_sensors(sensors):
	var available = []
	for i in range(sensors.size()):
		if sensors[i]:
			available.append(i)
	
	if available.size() == 0:
		print("NO AVAILABLE DIRECTIONS! STUCK!")
		dirs = [false, false, false, false]
		current_dir = -1
		return
	
	var dir = available[randi() % available.size()]

	
	# Prevent immediate reversal (optional)
	if dir == (current_dir + 2) % 4:
		if available.size() > 1:
			available.erase(dir)
			dir = available[randi() % available.size()]
	
	print("FROM DIR:", dir_labels[current_dir], " TO DIR:", dir_labels[dir], " FROM SENSORS:", sensors)
	current_dir = dir
	dirs = [dir == 0, dir == 1, dir == 2, dir == 3]

func _next_direction():
	dir += 1
	if dir >= 4:
		dir = 0
	if dir == 0:
		dirs = [true,false,false,false]
		return 
	if dir == 1:
		dirs = [false,true,false,false]
		return 
	if dir == 2:
		dirs = [false,false,true,false]
		return 
	if dir == 3:
		dirs = [false,false,false,true]
		return 

func _next_random_direction():
	dir = randi() % 4
	if dir == 0:
		dirs = [true,false,false,false]
		return 
	if dir == 1:
		dirs = [false,true,false,false]
		return 
	if dir == 2:
		dirs = [false,false,true,false]
		return 
	if dir == 3:
		dirs = [false,false,false,true]
		return 

func _physics_process(delta):
	var force = Vector2(0, 0)
	
	var walk_left = dirs[0]
	var walk_up = dirs[1]
	var walk_right = dirs[2]
	var walk_down = dirs[3]
	
	var stop = true
	
	if walk_left:
		if velocity.x <= WALK_MIN_SPEED and velocity.x > -WALK_MAX_SPEED:
			force.x -= WALK_FORCE
			stop = false
	if walk_right:
		if velocity.x >= -WALK_MIN_SPEED and velocity.x < WALK_MAX_SPEED:
			force.x += WALK_FORCE
			stop = false
	if walk_up:
		if velocity.y <= WALK_MIN_SPEED and velocity.y > -WALK_MAX_SPEED:
			force.y -= WALK_FORCE
			stop = false
	if walk_down:
		if velocity.y >= -WALK_MIN_SPEED and velocity.y < WALK_MAX_SPEED:
			force.y += WALK_FORCE
			stop = false
	
	if stop:
		var vsign = sign(velocity.x)
		var yvsign = sign(velocity.y)
		var vlen = abs(velocity.x)
		var yvlen = abs(velocity.y)
		
		vlen -= STOP_FORCE * delta
		yvlen -= STOP_FORCE * delta
		if vlen < 0:
			vlen = 0
		if yvlen < 0:
			yvlen = 0
		
		velocity.x = vlen * vsign
		velocity.y = yvlen * yvsign
	
	velocity += force * delta	
	velocity = move_and_slide(velocity, Vector2(0, 0), false, 4, PI/4, false)

	if (velocity.x == 0 && velocity.y == 0 ) or state_has_changed:
		#_next_direction()
		# _next_random_direction()
		_next_direction_from_sensors(free_sensors)
		state_has_changed = false

	for i in get_slide_count():
		var collision = get_slide_collision(i)
		if collision.collider.is_in_group("object"):
			collision.collider.apply_central_impulse(-collision.normal * inertia)
	#print("")
	if first_frame:
		print("Initial state: ", free_sensors)
		first_frame = false
		


func reset_to_start():
	position = start_position
	velocity = Vector2.ZERO  # optional: stop any current motion


func _on_Area2D_body_entered(body):
	if body.is_in_group("player"):
		print("Spelaren träffad av fiende!")
		emit_signal("player_hit")
		reset_to_start()

	# print("Actor entered", body)
