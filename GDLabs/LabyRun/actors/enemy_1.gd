extends KinematicBody2D

# --- CONSTANTS ---
const WALK_FORCE      := 300
const WALK_MIN_SPEED  := 10
const WALK_MAX_SPEED  := 25
const STOP_FORCE      := 600
const INERTIA         := 100

#const TURN_COOLDOWN: float = 1.0 # Time in seconds to prevent new turns
const TURN_COOLDOWN: float = 0.50 # Time in seconds to prevent new turns


# Directions (index mapping)
const LEFT   := 0
const UP     := 1
const RIGHT  := 2
const DOWN   := 3
const DIR_LABELS := ["left", "up", "right", "down"]

# --- VARIABLES ---
var velocity: Vector2 = Vector2.ZERO
var current_dir: int = -1  # current movement direction (0–3, or -1 for none)

# Sensor system
var sensor_hits := [0, 0, 0, 0]     # counters of overlapping walls
var free_sensors := [true, true, true, true]  # derived from hits

# State
var dirs := [true, false, false, false]   # active direction vector (like LEFT/UP/RIGHT/DOWN flags)
var start_position: Vector2
var state_has_changed := false
var first_frame := true

# Debug
export var debug_hits := false
export var debug_print := false
export var error_print := false

# --- SIGNALS ---
signal player_hit

var time_since_last_turn: float = 0.0

# --- READY ---
func _ready() -> void:
	add_to_group("enemies")
	start_position = position
	
	# Connect all 4 sensor areas dynamically
	var directions = {"Left": LEFT, "Up": UP, "Right": RIGHT, "Down": DOWN}
	for name in directions.keys():
		var idx = directions[name]
		var area = get_node("Area" + name)
		area.connect("body_entered", self, "_on_body_entered", [name.to_lower(), idx])
		area.connect("body_exited", self, "_on_body_exited", [name.to_lower(), idx])


# --- SENSOR HANDLING ---
# func _on_body_entered(body, direction: String, index: int) -> void:
# 	if _is_wall_like(body):
# 		sensor_hits[index] += 1
# 		free_sensors[index] = sensor_hits[index] == 0
		
# 		if debug_hits:
# 			get_node("Area" + direction.capitalize() + "/Highlight").visible = true
		
# 		_sight_state_changed(true, index)

	
# func _on_body_exited(body, direction: String, index: int) -> void:
# 	if _is_wall_like(body):
# 		sensor_hits[index] = max(sensor_hits[index] - 1, 0)
# 		free_sensors[index] = sensor_hits[index] == 0
		
# 		if debug_hits:
# 			get_node("Area" + direction.capitalize() + "/Highlight").visible = false
		
# 		_sight_state_changed(false, index)

func _on_body_entered(body, direction: String, index: int) -> void:
	if _is_wall_like(body):
		sensor_hits[index] += 1
		_sight_state_changed(true, index)

		if debug_hits:
			get_node("Area" + direction.capitalize() + "/Highlight").visible = true


	if _is_actor_like(body):
		# Apply a long cooldown after colliding with another actor.
		time_since_last_turn = -2.0 # A negative number makes the cooldown longer.
		# This prevents immediate reversal after a touch.

func _on_body_exited(body, direction: String, index: int) -> void:
	if _is_wall_like(body):
		sensor_hits[index] = max(sensor_hits[index] - 1, 0)
		_sight_state_changed(false, index)

		if debug_hits:
			get_node("Area" + direction.capitalize() + "/Highlight").visible = false


func _sight_state_changed(entered: bool, dir_index: int) -> void:
	if entered:
		# A wall has entered the sensor, so this direction is no longer free.
		free_sensors[dir_index] = false
	else:
		# A wall has exited, but we should only consider this direction free
		# if there are no other walls currently in the sensor area.
		free_sensors[dir_index] = sensor_hits[dir_index] == 0

	state_has_changed = true
	
	if debug_print:
		print("STATE CHANGED:", DIR_LABELS[dir_index], " is free:", free_sensors[dir_index])


# --- DIRECTION CHOICE ---
func _next_direction_from_sensors(sensors: Array) -> void:
	var available := []
	var forward_and_turn := []

	var reverse_dir: int = -1
	if current_dir != -1:
		reverse_dir = (current_dir + 2) % 4

	# Separate available directions into "forward/turn" and "reverse"
	for i in range(sensors.size()):
		if sensors[i]:
			if i == reverse_dir:
				available.append(i) # This is a last resort
			else:
				forward_and_turn.append(i)

	# Prioritize non-reverse directions
	var options: Array = forward_and_turn
	if options.empty():
		# If no forward/turn options exist, consider the reverse direction
		options = available
		if options.empty():
			print(name, " STUCK: no free directions")
			dirs = [false, false, false, false]
			current_dir = -1
			return

	# Choose randomly from the prioritized options
	var dir: int = options[randi() % options.size()]

	# Apply chosen direction
	current_dir = dir
	dirs = [dir == LEFT, dir == UP, dir == RIGHT, dir == DOWN]

	if debug_print:
		print("Direction changed to:", DIR_LABELS[dir], " Free:", sensors)

# --- PHYSICS ---
func _physics_process(delta: float) -> void:
	var force := Vector2.ZERO
	var stop := true
	
	# Apply directional movement forces
	if dirs[LEFT] and velocity.x > -WALK_MAX_SPEED:
		if velocity.x <= WALK_MIN_SPEED: 
			force.x -= WALK_FORCE
			stop = false
	if dirs[RIGHT] and velocity.x < WALK_MAX_SPEED:
		if velocity.x >= -WALK_MIN_SPEED: 
			force.x += WALK_FORCE
			stop = false
	if dirs[UP] and velocity.y > -WALK_MAX_SPEED:
		if velocity.y <= WALK_MIN_SPEED: 
			force.y -= WALK_FORCE
			stop = false
	if dirs[DOWN] and velocity.y < WALK_MAX_SPEED:
		if velocity.y >= -WALK_MIN_SPEED: 
			force.y += WALK_FORCE
			stop = false
	
	# Apply braking when no force applied
	if stop:
		velocity = _apply_brake(velocity, delta)
	
	time_since_last_turn += delta

	# Integrate motion
	velocity += force * delta   
	velocity = move_and_slide(velocity, Vector2.ZERO, false, 4, PI/4, false)
	
	# Check if a new direction is needed, considering the long actor cooldown.
	if (velocity == Vector2.ZERO) or \
		(state_has_changed and time_since_last_turn >= TURN_COOLDOWN):
		_next_direction_from_sensors(free_sensors)
		state_has_changed = false
		time_since_last_turn = 0.0 # Reset cooldown after a turn


	# Integrate motion
	velocity += force * delta
	# var prev_velocity = velocity
	velocity = move_and_slide(velocity, Vector2.ZERO, false, 4, PI/4, false)
	
	# Check for Actor-to-Actor collision
	for i in get_slide_count():
		var collision = get_slide_collision(i)
		if collision.collider.is_in_group("enemies"):
			# Break the oscillation with a small random impulse
			var push_direction = collision.normal.rotated(rand_range(-PI/8, PI/8))
			velocity = push_direction * (WALK_MAX_SPEED * 1.5)
			state_has_changed = true # Force a new direction choice after the push
			time_since_last_turn = 0.0
			return # Exit the function to prevent further movement logic this frame
	
	# Check if stuck or sensor state changed AND the turn cooldown is over
	if (is_zero_approx_vec(velocity) and time_since_last_turn >= TURN_COOLDOWN) or \
	   (state_has_changed and time_since_last_turn >= TURN_COOLDOWN):
		_next_direction_from_sensors(free_sensors)
		state_has_changed = false
		time_since_last_turn = 0.0 # Reset cooldown after a turn

	# Push objects with inertia
	for i in get_slide_count():
		var collision = get_slide_collision(i)
		if collision.collider.is_in_group("object"):
			collision.collider.apply_central_impulse(-collision.normal * INERTIA)
	
	# Debug: print initial state
	if first_frame:
		print("Initial free sensors:", free_sensors)
		first_frame = false

func is_zero_approx_vec(v: Vector2, tolerance: float = 0.00001) -> bool:
	return v.length_squared() < tolerance * tolerance


# --- HELPERS ---
func _apply_brake(v: Vector2, delta: float) -> Vector2:
	var x_sign = sign(v.x)
	var y_sign = sign(v.y)
	var x_mag = max(abs(v.x) - STOP_FORCE * delta, 0)
	var y_mag = max(abs(v.y) - STOP_FORCE * delta, 0)
	return Vector2(x_mag * x_sign, y_mag * y_sign)


func _is_wall_like(body: Node) -> bool:
	return (
		body.is_in_group("walls") or
		"Map" in body.name or
		"oneway" in body.name or
		"door" in body.name
	)

func _is_actor_like(body: Node) -> bool:
	return body.is_in_group("enemies") and self.name != body.name

# --- RESET & PLAYER COLLISION ---
func reset_to_start() -> void:
	position = start_position
	velocity = Vector2.ZERO


func _on_Area2D_body_entered(body) -> void:
	if body.is_in_group("player"):
		print("Player hit by enemy!")
		emit_signal("player_hit")
		reset_to_start()
