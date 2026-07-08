extends Node2D

onready var warpto = $To
onready var player = $"../player"

func _ready():
	pass


func _on_From_area_entered(area):
	player.position = warpto.position
