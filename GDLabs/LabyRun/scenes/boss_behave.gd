extends Area2D

onready var anim = $AnimationPlayer
onready var anim_tree = $AnimationTree
export var solution = 10
export var speed = 25
export var orbit_radius = 50.0

onready var label = $Label

# Hack until implemented inside Square Movement
var t = 0.0

onready var movement = preload("res://common_movement.gd").new()



func _ready():
	anim.get_animation("ZoomAnim").loop = true
	anim.get_animation("Strife").loop = true
	anim.get_animation("Idle").loop = true
	anim.get_animation("Wiggle").loop = true

	anim_tree.active = true
	anim_tree.set("parameters/BlendStrife/blend_amount", 0.0)
	anim_tree.set("parameters/BlendWiggle/blend_amount", 0.0)
	anim_tree.set("parameters/BlendZoom/blend_amount", 0.0)
	label.text = str(solution)
	movement.set_speed(speed)

func begin_strife():
	pass
	if anim_tree != null:
		anim_tree.set("parameters/BlendStrife/blend_amount", 0.0)
		anim_tree.set("parameters/BlendWiggle/blend_amount", 0.0)
		anim_tree.set("parameters/BlendZoom/blend_amount", 0.0)

var s = 0
func _process(delta):
	# anim_tree.advance(delta)
	# movement.move_square(self, delta, orbit_radius)
	# movement.bounce_in_box(self, delta, 50.0, 30.0)
	# movement.random_dots_square(self, delta, 50.0, 30.0)
	# var t = movement.orbit_enemy(self, delta, 75.0, s) 
	# if t > 7.6:
	# 	s = 0
	# 	movement.reset_timer()
	# elif t > 5.0:
	# 	s = 2
	# elif t > 2.6:
	# 	s = 1
	movement.random_dots_circle(self, delta, orbit_radius)

	movement.orbit_enemy(self, delta, orbit_radius, s)

	# var t = movement.orbit_enemy(self, delta, orbit_radius, s)

	# Hack untill implemented inside Square Movement
	t += 1 * delta

	if t <= 2.6:
		pass  # inget händer
	elif t <= 15.0:
		s = 1
	elif t <= 17.6:
		s = 2
	else:
		s = 0
		movement.reset_timer()

func _on_boss_body_entered(body):
	if not body.is_in_group("player"):
		return
	anim_tree.set("parameters/SeekStrife/seek_position", 0.0)
	anim_tree.set("parameters/SeekWiggle/seek_position", 0.0)
	anim_tree.set("parameters/SeekZoom/seek_position", 0.0)
	movement.reset_enemy(self)
	s = 0

func decrese_hp(value):	
	solution -= value
	label.text = str(solution)
	if solution == 0:
		var global = get_node("/root/Global")
		global.next_maze_index += 1
		var path = "res://maps/maze_" + str(global.next_maze_index) + ".tscn"
		var err = get_tree().change_scene(path)
		if err != 0:
			print('Failed to load next level ' + path)
			return
		print('Load next level ' + path)
