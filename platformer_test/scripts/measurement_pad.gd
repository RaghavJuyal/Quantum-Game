extends Area2D

@onready var game_manager: Node = %GameManager

func _on_body_entered(body: Node2D) -> void:
	if !game_manager.entangled_mode:
		game_manager.measure()
	else:
		game_manager.measure_entangled()
