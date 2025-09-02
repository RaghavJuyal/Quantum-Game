extends Node

var score = 0

@export var hud: CanvasLayer

func _ready() -> void:
	score = 0

func add_point():
	score += 1
	hud.get_node("CoinsLabel").text = str(score)
	


func _process(delta: float) -> void:
	pass
