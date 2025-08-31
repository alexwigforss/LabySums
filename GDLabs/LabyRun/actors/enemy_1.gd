extends KinematicBody2D

# --- CONSTANTS ---
const WALK_FORCE      := 600
const WALK_MIN_SPEED  := 10
const WALK_MAX_SPEED  := 25
const STOP_FORCE      := 1300
const INERTIA         := 100

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

# --- SIGNALS ---
signal player_hit


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
func _on_body_entered(body, direction: String, index: int) -> void:
	if _is_wall_like(body):
		sensor_hits[index] += 1
		free_sensors[index] = sensor_hits[index] == 0
		
		if debug_hits:
			get_node("Area" + direction.capitalize() + "/Highlight").visible = true
		
		_sight_state_changed(true, index)

func _on_body_exited(body, direction: String, index: int) -> void:
	if _is_wall_like(body):
		sensor_hits[index] = max(sensor_hits[index] - 1, 0)
		free_sensors[index] = sensor_hits[index] == 0
		
		if debug_hits:
			get_node("Area" + direction.capitalize() + "/Highlight").visible = false
		
		_sight_state_changed(false, index)

func _sight_state_changed(entered: bool, dir_index: int) -> void:
	free_sensors[dir_index] = not entered
	if not entered:
		state_has_changed = true
	
	if debug_print:
		print("STATE CHANGED:", DIR_LABELS[dir_index], " is free:", free_sensors[dir_index])


# --- DIRECTION CHOICE ---
func _next_direction_from_sensors(sensors: Array) -> void:
	var available := []
	for i in range(sensors.size()):
		if sensors[i]:
			available.append(i)

	if available.empty():
		print(name, " STUCK: no free directions")
		dirs = [false, false, false, false]
		current_dir = -1
		return

	var dir: int = -1

	# --- 50/50 chance to continue straight ---
	if current_dir >= 0 and sensors[current_dir] and available.size() > 1:
		if randi() % 2 == 0:
			# Continue straight
			dir = current_dir
		else:
			# Pick another direction randomly (excluding current)
			var options := available.duplicate()
			options.erase(current_dir)
			dir = options[randi() % options.size()]
	else:
		# Otherwise pick randomly from available
		dir = available[randi() % available.size()]

	# --- Avoid immediate reversal if alternatives exist ---
	var reverse: int = (current_dir + 2) % 4
	if dir == reverse and available.size() > 1:
		available.erase(reverse)
		dir = available[randi() % available.size()]

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
	
	# Integrate motion
	velocity += force * delta	
	velocity = move_and_slide(velocity, Vector2.ZERO, false, 4, PI/4, false)

	# Check if stuck or sensor state changed
	if (velocity == Vector2.ZERO) or state_has_changed:
		_next_direction_from_sensors(free_sensors)
		state_has_changed = false

	# Push objects with inertia
	for i in get_slide_count():
		var collision = get_slide_collision(i)
		if collision.collider.is_in_group("object"):
			collision.collider.apply_central_impulse(-collision.normal * INERTIA)
	
	# Debug: print initial state
	if first_frame:
		print("Initial free sensors:", free_sensors)
		first_frame = false


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
		"RigidBodyDoor" in body.name or
		"monster" in body.name
	)


# --- RESET & PLAYER COLLISION ---
func reset_to_start() -> void:
	position = start_position
	velocity = Vector2.ZERO

func _on_Area2D_body_entered(body) -> void:
	if body.is_in_group("player"):
		print("Player hit by enemy!")
		emit_signal("player_hit")
		reset_to_start()
