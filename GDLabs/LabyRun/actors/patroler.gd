extends KinematicBody2D
# Todo move between sides in targets
var start_position: Vector2
var velocity: Vector2 = Vector2.ZERO

func _ready():
	start_position = position


func reset_to_start() -> void:
	position = start_position
	velocity = Vector2.ZERO

func _on_Area2D_body_entered(body) -> void:
	if body.is_in_group("player"):
		print("Player hit by enemy_1 !")
		emit_signal("player_hit")
		reset_to_start()


