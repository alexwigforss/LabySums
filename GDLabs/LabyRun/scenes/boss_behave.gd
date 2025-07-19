extends Area2D

onready var anim = $AnimationPlayer
onready var anim_tree = $AnimationTree

func _ready():
	anim.get_animation("ZoomAnim").loop = true
	anim.get_animation("Strife").loop = true
	anim.get_animation("Idle").loop = true
	anim.get_animation("Wiggle").loop = true

	anim_tree.active = true
	anim_tree.set("parameters/BlendStrife/blend_amount", 0.0)
	anim_tree.set("parameters/BlendWiggle/blend_amount", 0.0)
	anim_tree.set("parameters/BlendZoom/blend_amount", 0.0)

func begin_strife():
	anim_tree.set("parameters/BlendStrife/blend_amount", 1.0)
	

func _process(delta):
	anim_tree.advance(delta)
