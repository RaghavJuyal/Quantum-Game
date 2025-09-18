extends Node

@onready var game_manager: Node = %GameManager
@onready var key: Node = $"."

func _on_body_entered(body: Node2D) -> void:
	print("Reached Key")
	var state = game_manager.measure()
	if (body.is_state_zero and state==0) or (not body.is_state_zero and state == 1):
		game_manager.add_point()
		key.queue_free()
