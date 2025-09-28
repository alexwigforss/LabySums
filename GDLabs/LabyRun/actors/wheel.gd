extends KinematicBody2D

# Movement settings
export (int) var speed := 20
export (float) var rotation_speed := 2.0
export (bool) var randomize_turns := true
export (bool) var sensing := false
export (bool) var clock_wise := true

var velocity := Vector2.ZERO
var current_dir_index := 0
var prev_direction := -1

# Ordered directions (clockwise)
var directions := [
	Vector2.DOWN,   # 0
	Vector2.RIGHT,  # 1
	Vector2.UP,     # 2
	Vector2.LEFT    # 3
]

const DIR_LABELS := ["down", "right", "up", "left"]

func _ready() -> void:
	# Rotation direction
	if not clock_wise:
		rotation_speed = -rotation_speed

	# Start moving down
	velocity = directions[current_dir_index] * speed
	
	# Connect sensors if enabled
	if sensing:
		var sense_dirs = {"Left": 3, "Up": 2, "Right": 1, "Down": 0}
		for name in sense_dirs.keys():
			var idx = sense_dirs[name]
			var area = get_node("Sensors/Area" + name)
			area.connect("body_exited", self, "_on_body_exited", [name.to_lower(), idx])

	_choose_new_direction()


func _physics_process(delta: float) -> void:
	# Spin wheel
	$Sprite.rotation += rotation_speed * delta

	# Move and detect collisions
	var collision = move_and_collide(velocity * delta)
	if collision:
		var col: Node = collision.collider
		if col.is_in_group("wall") or col.is_in_group("player") or col.is_in_group("enemies"):
			_choose_new_direction()


func _on_body_exited(body: Node, direction: String, index: int) -> void:
	if not _is_wall_like(body):
		return

	# Infer previous movement direction
	if velocity.x > 0:
		prev_direction = 3  # LEFT
	elif velocity.x < 0:
		prev_direction = 1  # RIGHT
	elif velocity.y > 0:
		prev_direction = 2  # UP
	elif velocity.y < 0:
		prev_direction = 0  # DOWN

	if index != prev_direction:
		_choose_new_direction()
		velocity = directions[current_dir_index] * speed
		print("DIR:", direction, " EXITED:", body.name, " VELOCITY:", velocity, " INDEX:", index)
	else:
		print("SKIPPED DIR:", direction, " EXITED:", body.name, " VELOCITY:", velocity, " INDEX:", index)


func _is_wall_like(body: Node) -> bool:
	return (
		body.is_in_group("walls")
		or "Map" in body.name
		or "oneway" in body.name
		or "RigidBodyDoor" in body.name
	)


func _choose_new_direction() -> void:
	if randomize_turns:
		# If moving vertically → choose left or right
		if current_dir_index == 0 or current_dir_index == 2: 
			current_dir_index = 1 if randi() % 2 == 0 else 3
		# If moving horizontally → choose up or down
		else: 
			current_dir_index = 0 if randi() % 2 == 0 else 2
	else:
		# Deterministic clockwise/counter-clockwise
		if clock_wise:
			current_dir_index += 1
			if current_dir_index >= directions.size():
				current_dir_index = 0
		else:
			current_dir_index -= 1
			if current_dir_index < 0:
				current_dir_index = directions.size() - 1

	print("New direction =", current_dir_index, DIR_LABELS[current_dir_index])
	velocity = directions[current_dir_index] * speed
