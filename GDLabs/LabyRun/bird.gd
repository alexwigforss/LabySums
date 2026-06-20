extends AnimatedSprite
var direction;

func _ready():
	direction = Vector2(0.0,0.0)

func set_direction(v):
	direction = Vector2(v)
