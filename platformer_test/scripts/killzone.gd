extends Area2D

@onready var timer: Timer = $Timer
@onready var game_manager: Node = %GameManager

func _on_body_entered(body: Node2D) -> void:
	var state = game_manager.measure()
	if (body.is_state_zero and state==0) or (not body.is_state_zero and state == 1):
		Engine.time_scale = 0.5
		body.get_node("CollisionShape2D").queue_free()
		game_manager.schedule_respawn()
