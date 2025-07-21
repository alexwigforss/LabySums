extends Node
class_name Movement

var speed = 20
var r = 0.0
var orb_x = 0.0;
var orb_y = 0.0;
var i = 0.0
var timer = 0.0
# Global list of two points to move between
var path_points: Array = [Vector2(0, -100), Vector2(0, 100)]
var moving_towards_index: int = 1  # Index of current target (either 0 or 1)

func move_enemy(enemy: Node2D, direction: Vector2, delta: float):
	enemy.position += direction.normalized() * speed * delta


func orbit(pos_x,pos_y,r,delta: float):
	var x = pos_x + cos(i) * r;
	var y = pos_y + sin(i) * r;
	i += 5 * delta
	#print(i)
	return Vector2(x, y)

func reset_index():
	i = 0.0

func reset_timer():
	timer = 0.0

# NOTE mby return radius or an overload could be usefull	
func orbit_enemy(enemy: Node2D, delta: float, max_radius: float, state: int):
	if state == 4:
		return timer
	if state == 0 and r < max_radius:
		r += 0.1
	if state == 2 and r > 0.0:
		r -= 0.1
	var new_position = orbit(enemy.position.x,enemy.position.y,r,delta)
	enemy.position = new_position
	timer += 1 * delta
	return timer


func move_point_to_point(enemy: Node2D, delta: float):
	var target = path_points[moving_towards_index]
	var direction = (target - enemy.position).normalized()
	
	enemy.position += direction * speed * delta

	# Check if enemy is close to the target
	if enemy.position.distance_to(target) < 1.0:
		# Flip target index between 0 and 1
		moving_towards_index = 1 - moving_towards_index

func reset_enemy(enemy: Node2D):
	enemy.position = path_points[0]
	moving_towards_index = 1
	r = 0.0

