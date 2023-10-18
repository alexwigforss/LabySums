extends KinematicBody2D
signal custom_signal
signal goal_signal
signal door_signal
# Member variables
const GRAVITY = 0.0 # pixels/second/second

# Angle in degrees towards either side that the player can consider "floor"
const FLOOR_ANGLE_TOLERANCE = 40
const WALK_FORCE = 600
const WALK_MIN_SPEED = 10
const WALK_MAX_SPEED = 200
const STOP_FORCE = 1300

const SLIDE_STOP_VELOCITY = 1.0 # one pixel/second
const SLIDE_STOP_MIN_TRAVEL = 1.0 # one pixel

var velocity = Vector2()
var strength = 0
#var on_air_time = 100
#var jumping = false
var inertia = 100

func _ready():
	$Label.text = str(strength)

func _physics_process(delta):
	# Create forces
	var force = Vector2(0, 0)
	
	var walk_left = Input.is_action_pressed("move_left")
	var walk_right = Input.is_action_pressed("move_right")
	var walk_up = Input.is_action_pressed("move_up")
	var walk_down = Input.is_action_pressed("move_down")
	#var jump = Input.is_action_pressed("jump")
	
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
	
	for i in get_slide_count():
		var collision = get_slide_collision(i)
		if collision.collider.is_in_group("object"):
			collision.collider.apply_central_impulse(-collision.normal * inertia)

func _on_pickup_body_entered(_body):
	print("body entered pickup")
	strength += 1
	$Label.text = str(strength)
	print(strength);

func _on_MonsterArea2D_body_entered(_body):
	emit_signal("custom_signal",strength)

func _on_goal_entered(_body):
	print("body entered goal")
	emit_signal("goal_signal",strength)



func _on_door_body_entered(body):
	print("body entered door")
	emit_signal("door_signal",strength,body)
