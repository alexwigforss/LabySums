extends Area2D

onready var anim = $AnimationPlayer

func _ready():
	while true:
		anim.play("Strife")
		yield(anim, "animation_finished")

#	anim.play("ZoomAnim")
#	yield(anim, "animation_finished")
#	anim.play("Strife")
#	yield(anim, "animation_finished")
#	anim.play("Wiggle")
#	yield(anim, "animation_finished")
