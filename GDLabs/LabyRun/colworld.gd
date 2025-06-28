extends Node2D

#var _label
var _current_level
#var active_map_nr = 1
var current_segment_id = 1
onready var emitting_actor = get_node("/root/colworld/player")

func _ready():
	#_label = get_node("player/Camera2D/ColorRect/MainLabel")
	_current_level = get_node("/root/colworld/Map" + str(current_segment_id))
	
# The prototype for the boss level
# Not to be confusade with segment doors.
func _on_goal_body_entered(body):
	print("Signal from goal")


func _on_ResetButton_pressed():
	get_tree().reload_current_scene()

func reset_segment():
	_current_level.clear_nums_and_ops()
	# var emitting_actor = get_node("/root/colworld/player")
	emitting_actor.reset_strength()
	

func _on_ResetSegment_pressed():
	print("Reset Segment Button Pressed!")
	reset_segment()

func update_current_segment():
	current_segment_id +=1
	_current_level = get_node("/root/colworld/Map" + str(current_segment_id))
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
