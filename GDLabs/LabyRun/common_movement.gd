extends Node
class_name Movement

var speed = 20

# Global list of two points to move between
var path_points: Array = [Vector2(0, -100), Vector2(0, 100)]
var moving_towards_index: int = 1  # Index of current target (either 0 or 1)

func move_enemy(enemy: Node2D, direction: Vector2, delta: float):
    enemy.position += direction.normalized() * speed * delta

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