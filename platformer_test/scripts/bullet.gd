extends Node2D

const SPEED = 40
var direction = -1

func _process(delta: float) -> void:
	position.x += direction * SPEED * delta
	pass
