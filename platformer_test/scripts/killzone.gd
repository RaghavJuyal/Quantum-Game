extends Area2D

@onready var timer: Timer = $Timer
@onready var game_manager: Node = get_tree().root.get_node("Game/GameManager")

func _on_body_entered(body: Node2D) -> void:
	# Measure on interaction with the killzone
	var measured_state = null
	if !game_manager.entangled_mode:
		measured_state = game_manager.measure()
	else:
		measured_state = game_manager.measure_entangled()
	if (body.is_state_zero and measured_state == 0) or (not body.is_state_zero and measured_state == 1):
		Engine.time_scale = 0.5
		#body.get_node("CollisionShape2D").disabled = true
		game_manager.schedule_respawn(body)
