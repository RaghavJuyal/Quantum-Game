extends Area2D

@onready var game_manager: Node = %GameManager

var pos = self.global_position

func _on_body_entered(body: Node2D) -> void:
	# Detects if player touches measurement pad
	var state = game_manager.measure()
	if (body.is_state_zero and state==0) or (not body.is_state_zero and state == 1):
		game_manager.spawn_pos = pos
