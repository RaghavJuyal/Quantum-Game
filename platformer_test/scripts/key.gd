extends Node

@onready var game_manager: Node = %GameManager
@onready var key: Node = $"."

func _on_body_entered(body: Node2D) -> void:
	if Input.is_action_pressed("c_not"):
		body.entangled_colour()
		key.queue_free()
	else:
		print("can't cnot")