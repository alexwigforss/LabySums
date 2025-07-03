extends KinematicBody2D
const GRAVITY = 0.0 # pixels/second/second

# Angle in degrees towards either side that the player can consider "floor"
const FLOOR_ANGLE_TOLERANCE = 40
const WALK_FORCE = 600
const WALK_MIN_SPEED = 10
const WALK_MAX_SPEED = 50
const STOP_FORCE = 1300

const SLIDE_STOP_VELOCITY = 1.0 # one pixel/second
const SLIDE_STOP_MIN_TRAVEL = 1.0 # one pixel

var velocity = Vector2()
var strength = 0
var inertia = 100
var dir = 0
var dirs = [true,false,false,false]

signal player_hit
var start_position := Vector2.ZERO

func _ready():
	start_position = position
	#$Label.text = str(velocity)
	pass
	
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
	# Create forces
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
	
	# Integrate forces to velocity
	velocity += force * delta	
	# Integrate velocity into motion and move
	velocity = move_and_slide(velocity, Vector2(0, 0), false, 4, PI/4, false)
	#$Label.text = str(velocity)

	if velocity.x == 0 && velocity.y == 0:
		#_next_direction()
		_next_random_direction()

	for i in get_slide_count():
		var collision = get_slide_collision(i)
		if collision.collider.is_in_group("object"):
			collision.collider.apply_central_impulse(-collision.normal * inertia)


func reset_to_start():
	position = start_position
	velocity = Vector2.ZERO  # optional: stop any current motion


func _on_pickup_body_entered(body):
	if body.is_in_group("player"):
		strength += 1
		$Label.text = str(strength)
		print(body," entered actor ",strength)


func _on_door_body_entered(_body):
	print("body entered door")
	# emit_signal("door_signal",strength,body)


func _on_Area2D_body_entered(body):
	if body.is_in_group("player"):
		print("Spelaren träffad av fiende!")
		emit_signal("player_hit")
		reset_to_start()

	print("Actor entered", body)
