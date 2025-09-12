# VARNING, kan bråka med fienderna i synnerhet de som använder numerisk representation för navigation
# De övriga kan nog fixas genom att låta dem känna av och studsa mot hjulet
extends KinematicBody2D

export (int) var speed = 20
export (float) var rotation_speed = 2
export (bool) var randomize_turns = true

var velocity = Vector2()

# Möjliga riktningar i clockwise ordning
var directions = [
	Vector2.DOWN,
	Vector2.RIGHT,
	Vector2.UP,
	Vector2.LEFT
]

var current_dir_index = 0

func _ready():
	# Starta med nedåt (index 0)
	velocity = directions[current_dir_index] * speed

func _physics_process(delta):
	# Snurra hjulet alltid
	rotation += rotation_speed * delta

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
		# Gå till nästa riktning i listan (clockwise)
		current_dir_index = (current_dir_index + 1) % directions.size()

	# Uppdatera velocity baserat på den nya riktningen
	velocity = directions[current_dir_index] * speed


# extends KinematicBody2D

# export (int) var speed = 20
# export (float) var rotation_speed = 2

# var velocity = Vector2()

# func _ready():
# 	velocity = Vector2(speed, 0)

# func _physics_process(delta):
# 	# Snurra hjulet alltid
# 	rotation += rotation_speed * delta

# 	# Försök flytta hjulet
# 	var collision = move_and_collide(velocity * delta)

# 	if collision:
# 		# Bara vänd om ifall vi träffar en vägg
# 		if collision.collider.is_in_group("wall") or collision.collider.is_in_group("player"):
# 			rotation_speed = -rotation_speed
# 			speed = -speed
# 			velocity = Vector2(speed, 0)
