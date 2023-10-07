extends KinematicBody2D

# This demo shows how to build a kinematic controller.

# Member variables
const GRAVITY = 0.0 # pixels/second/second

# Angle in degrees towards either side that the player can consider "floor"
const FLOOR_ANGLE_TOLERANCE = 40
const WALK_FORCE = 600
const WALK_MIN_SPEED = 10
const WALK_MAX_SPEED = 200
const STOP_FORCE = 1300
#const JUMP_SPEED = 200
#const JUMP_MAX_AIRBORNE_TIME = 0.2

const SLIDE_STOP_VELOCITY = 1.0 # one pixel/second
const SLIDE_STOP_MIN_TRAVEL = 1.0 # one pixel

var velocity = Vector2()
var strength = 0
#var on_air_time = 100
#var jumping = false
var inertia = 100

#var prev_jump_pressed = false


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
	#velocity = move_and_slide(velocity, Vector2(0, 0))
	velocity = move_and_slide(velocity, Vector2(0, 0), false, 4, PI/4, false)
	
	for i in get_slide_count():
		var collision = get_slide_collision(i)
		if collision.collider.is_in_group("object"):
			collision.collider.apply_central_impulse(-collision.normal * inertia)
			
#	for body in $Area2D.get_overlapping_bodies():
#		if body.is_in_group("picks"):
#			body.queue_free()
#	if is_on_floor():
#		on_air_time = 0
#
#	if jumping and velocity.y > 0:
#		# If falling, no longer jumping
#		jumping = false
#
#	if on_air_time < JUMP_MAX_AIRBORNE_TIME and jump and not prev_jump_pressed and not jumping:
#		# Jump must also be allowed to happen if the character left the floor a little bit ago.
#		# Makes controls more snappy.
#		velocity.y = -JUMP_SPEED
#		jumping = true
	
#	on_air_time += delta
#	prev_jump_pressed = jump


func _on_pickup_body_entered(_body):
	strength += 1
	print(strength);
