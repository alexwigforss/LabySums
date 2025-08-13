extends Node2D

var _current_level
export var number_of_segments = 9
var current_segment_id = 1
onready var emitting_actor = get_node("/root/colworld/player")
onready var boss_node = get_node("/root/colworld/BossGlobalTransform/boss")

func _ready():
	_current_level = get_node("/root/colworld/Map" + str(current_segment_id))
	
	for enemy in get_tree().get_nodes_in_group("enemies"):
		enemy.connect("player_hit", self, "_on_enemy_player_hit")

func _on_goal_body_entered(body):
	print("Signal from goal")

func _on_enemy_player_hit():
	reset_segment()

func _on_ResetButton_pressed():
	get_tree().reload_current_scene()

func reset_segment():
	_current_level.clear_nums_and_ops()
	emitting_actor.reset_strength()
	print("Reseting segment", current_segment_id)
	print("X ",_current_level.start_pos.x," Y ",_current_level.start_pos.y)
	emitting_actor.position = Vector2(
		_current_level.position.x + 8 + (_current_level.start_pos.x * 16),
		_current_level.position.y + 8 + (_current_level.start_pos.y * 16)
		)
	

func _on_ResetSegment_pressed():
	print("Reset Segment Button Pressed!")
	reset_segment()

# TODO Get BossMap here if out of maps
func update_current_segment():
	current_segment_id +=1
	if current_segment_id < number_of_segments:
		_current_level = get_node("/root/colworld/Map" + str(current_segment_id))
	elif current_segment_id == number_of_segments:
		print("BAMM Entered Boss Segment!")
		_current_level = get_node("/root/colworld/BossMap")
		boss_node.begin_strife()
		emitting_actor.boss_segment_entered()
	print("Current segment = ", current_segment_id)


func _on_door_nomatch(nr):
	pass


func _on_door_match(_nr):
	print("On door match")
	var previous = get_node("/root/colworld/Map"+ str(current_segment_id-1))  # Ersätt "SiblingNodeName" med det faktiska namnet
	if previous is Node2D:
		previous.modulate.a = 0.5  # Ändrar alpha-värdet till 0.5
	_current_level = get_node("/root/colworld/Map" + str(current_segment_id))
	if _current_level is Node2D:
		_current_level.modulate.a = 1  # Ändrar alpha-värdet till 0.5


func _on_boss_body_entered(body):
	print("Signal from boss")
	if not body.is_in_group("player"):
		if body.is_in_group("wall"):
			print("Boss entered wall")
		return
	reset_segment()
