extends Control

var start_map = 1
var number_of_levels = 2
onready var continue_button = get_node("VBoxContainer/ContinueButton")
onready var about_panel = get_node("About")

var continue_button_text = "CONTINUE"
func _ready():
	pass

func _on_AboutButton_pressed():
	about_panel.show()


func _on_AudioButton_pressed():
	print("Hello Audio!")


func _on_ContinueButton_pressed():
	start_map += 1
	if start_map > number_of_levels:
		start_map = 1
		continue_button.text = continue_button_text
	else:
		continue_button.text = continue_button_text + " " + str(start_map)

func _on_StartButton_pressed():
	var global = get_node("/root/Global")
	# var music = get_node("/root/AudioStreamPlayer")
	# Attempt to call function 'stop' in base 'null instance' on a null instance.
	# music.stop()

	global.next_maze_index = start_map
	var path = "res://maps/maze_" + str(global.next_maze_index) + ".tscn"
	var err = get_tree().change_scene(path)
	if err != 0:
		print('Failed to load next level ' + path)
		return
	print('Load next level ' + path)

