# VARNING, kan bråka med fienderna i synnerhet de som använder numerisk representation för navigation
# De övriga kan nog fixas genom att låta dem känna av och studsa mot hjulet
extends KinematicBody2D

export (int) var speed = 20
export (float) var rotation_speed
export (bool) var randomize_turns = true
export var sensing = false
export var clock_wise = true
var velocity = Vector2()

# Möjliga riktningar i clockwise ordning
var directions = [
	Vector2.DOWN,
	Vector2.RIGHT,
	Vector2.UP,
	Vector2.LEFT
]

# Directions (index mapping)
const LEFT   := 0
const UP     := 1
const RIGHT  := 2
const DOWN   := 3

const DIR_LABELS := ["left", "up", "right", "down"]


# Clockwise / counter-clockwise transitions
const CLOCKWISE_TURNS = {
	DOWN: RIGHT,
	RIGHT: UP,
	UP: LEFT,
	LEFT: DOWN
}

const COUNTER_TURNS = {
	DOWN: LEFT,
	LEFT: UP,
	UP: RIGHT,
	RIGHT: DOWN
}

var current_dir_index = 0

func _ready():
	if clock_wise:
		rotation_speed = 2.0
	else:
		rotation_speed = -2.0
	# Starta med nedåt (index 0)
	velocity = directions[current_dir_index] * speed
	
	if sensing:
		var sense_dirs = {"Left": LEFT, "Up": UP, "Right": RIGHT, "Down": DOWN}
		for name in sense_dirs.keys():
			var idx = sense_dirs[name]
			var area = get_node("Sensors/Area" + name)
			# area.connect("body_entered", self, "_on_body_entered", [name.to_lower(), idx])
			area.connect("body_exited", self, "_on_body_exited", [name.to_lower(), idx])

	_choose_new_direction()

var prev_direction

func _on_body_exited(body, direction: String, index: int) -> void:
	if _is_wall_like(body):
		if index != prev_direction:

			if velocity.x > 0:
				prev_direction = LEFT
			if velocity.x < 0:
				prev_direction = RIGHT
			if velocity.y > 0:
				prev_direction = UP
			if velocity.y < 0:
				prev_direction = DOWN

			print("INDEX: ", index, " PREV_DIR: ", prev_direction)
			if index != prev_direction:
				_choose_new_direction()
				velocity = directions[current_dir_index] * speed
				print("DIR: ", direction, " PREV_DIR: ", prev_direction, " EXITED: ", body, " VELOCITY: ", velocity, " INDEX: ", index)
			else:
				print("SKIPPED!")



func _is_wall_like(body: Node) -> bool:
	return (
		body.is_in_group("walls") or
		"Map" in body.name or
		"oneway" in body.name or
		"RigidBodyDoor" in body.name
	)


func _physics_process(delta):
	# Snurra hjulet alltid
	$Sprite.rotation += rotation_speed * delta

	# Försök flytta hjulet
	var collision = move_and_collide(velocity * delta)

	if collision:
		# Bara reagera på väggar
		if collision.collider.is_in_group("wall") or collision.collider.is_in_group("player")or collision.collider.is_in_group("enemies"):
			_choose_new_direction()


func _choose_new_direction():
	if randomize_turns:
		# Om vi rör oss vertikalt (UP/DOWN) -> välj LEFT eller RIGHT
		if current_dir_index == 0 or current_dir_index == 2:
			current_dir_index = randi() % 2 + 1  # 1 = RIGHT, 2 = UP
			# Men vi måste justera korrekt: om vi var nere (0) eller uppe (2)
			if current_dir_index == 2:
				current_dir_index = 3  # istället LEFT
		# Om vi rör oss horisontellt (RIGHT/LEFT) -> välj UP eller DOWN
		else:
			if randi() % 2 == 0:
				current_dir_index = 0  # DOWN
			else:
				current_dir_index = 2  # UP

	else:
		# Deterministic rotation: clockwise or counter-clockwise
		if clock_wise: # and previus direction is down
			current_dir_index = (current_dir_index + 1) % directions.size()
		elif clock_wise: # and previus direction is up
			current_dir_index = (current_dir_index + 1) % directions.size()
		# ... and so on ...
		else: 
			current_dir_index = (current_dir_index - 1 + directions.size()) % directions.size()

	print("New direction = ", current_dir_index, " ", DIR_LABELS[current_dir_index])

	# Uppdatera velocity baserat på den nya riktningen
	velocity = directions[current_dir_index] * speed
