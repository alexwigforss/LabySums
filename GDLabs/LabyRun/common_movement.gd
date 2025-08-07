extends Node
class_name Movement

var orbit_center = Vector2.ZERO
var target = Vector2.ZERO
var speed = 20
var current_radius = 0.0
var orb_x = 0.0;
var orb_y = 0.0;
var i = 0.0
var timer = 0.0
# Global list of two points to move between
var path_points: Array = [Vector2(0, -100), Vector2(0, 100)]
# var bounce_box_corners: Array = [Vector2(-100, -100), Vector2(100, -100),Vector2(100, 100), Vector2(-100, 100)]

var moving_towards_index: int = 0  # Index of current target (either 0 or 1)

func set_speed(new_speed: int):
	self.speed = new_speed

func move_enemy(enemy: Node2D, direction: Vector2, delta: float):
	enemy.position += direction.normalized() * speed * delta

# TODO Mby implement timer here two for more precise control
func move_square(actor: Node2D, delta: float, half_width: int):
	var h_w = half_width
	var box_points: Array = [Vector2(-h_w, -h_w), Vector2(h_w, -h_w),Vector2(h_w, h_w), Vector2(-h_w, h_w)]	
	target = box_points[moving_towards_index]
	var direction = (target - actor.position).normalized()
	actor.position += direction * speed * delta

	# Check if enemy is close to the target
	if actor.position.distance_to(target) < 1.0:
		# Flip target index between 0 and 1
		if moving_towards_index < 3:
			moving_towards_index += 1
		elif moving_towards_index > 2:
			moving_towards_index = 0

	# print("Moved Square Index: ", moving_towards_index, "Direction: ", direction)

var direction = (Vector2(0.5,0.5))

func bounce_in_box(actor: Node2D, delta: float, half_width: float, half_height: float):
	actor.position += direction * speed * delta
	if actor.position.x > orbit_center.x + half_width or actor.position.x < orbit_center.x - half_width:
		direction.x = 1 * -direction.x 
	if actor.position.y > orbit_center.y + half_height or actor.position.y < orbit_center.y - half_height:
		direction.y = 1 * -direction.y 
	


func random_dots_square(actor: Node2D, delta: float, half_width: float, half_height: float):
	direction = (target - actor.position).normalized()
	actor.position += direction * speed * delta
	if actor.position.distance_to(target) < 1.0:
		target.x = rand_range(orbit_center.x - half_width, orbit_center.x + half_width)
		target.y = rand_range(orbit_center.y - half_height, orbit_center.y + half_height)

func random_dots_circle(actor: Node2D, delta: float, r: float):
	direction = (target - actor.position).normalized()
	actor.position += direction * speed * delta
	if actor.position.distance_to(target) < 1.0:
		var angle = randf() * TAU
		var radius = sqrt(randf()) * r
		target.x = orbit_center.x + cos(angle) * radius
		target.y = orbit_center.y + sin(angle) * radius
	

func _orbit(center: Vector2, r: float, delta: float) -> Vector2:
	# Beräkna hur snabbt vinkeln ska ändras för att motsvara speed i världen
	var angular_speed = 0.0
	if r != 0.0:
		angular_speed = speed / r  # rad/s
		
	i += angular_speed * delta

	var x = center.x + cos(i) * r
	var y = center.y + sin(i) * r
	return Vector2(x, y)



# TODO Overload with internaly managed state
func orbit_enemy(actor: Node2D, delta: float, max_radius: float, state: int):
	# Make the actor orbit around its origin with a increasing or decreasing
	# radius caused by state.
	# EXAMPLE USAGE
	# var time = movement.orbit_enemy(self, delta, 25.0, state) 
	# if time > 5:
	# 	state = 1
	# elif time > 10:
	# 	state = 2
	# elif time > 15:
	# 	state = 0
	# 	movement.reset_timer()
	# print("Current radius: ", current_radius, " Timer: ", timer, " State: ", state)
	if state == 4:
		return timer
	if state == 0 and current_radius < max_radius:
		current_radius += 0.5
	if state == 2 and current_radius > 0.0:
		current_radius -= 0.5
	var new_position = _orbit(orbit_center, current_radius, delta)
	#var new_position = _orbit(actor.position.x,actor.position.y,current_radius,delta)
	actor.position = new_position
	timer += 1 * delta
	return timer

#func orbit_square(actor: Node2D, delta: float, max_radius: float, state: int):
#	pass



func move_point_to_point(enemy: Node2D, delta: float):
	var target = path_points[moving_towards_index]
	var direction = (target - enemy.position).normalized()
	
	enemy.position += direction * speed * delta

	# Check if enemy is close to the target
	if enemy.position.distance_to(target) < 1.0:
		# Flip target index between 0 and 1
		moving_towards_index = 1 - moving_towards_index

func reset_index():
	i = 0.0

func reset_timer():
	timer = 0.0

func reset_enemy(enemy: Node2D):
	enemy.position = Vector2(0,0)
	moving_towards_index = 0
	current_radius = 0.0
	reset_timer()

