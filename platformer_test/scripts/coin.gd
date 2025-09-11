extends Area2D

@onready var game_manager: Node = %GameManager

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _on_body_entered(body: Node2D) -> void:
	# Detects if player touches coin
	var state = game_manager.measure()
	if (body.is_state_zero and state==0) or (not body.is_state_zero and state == 1):
		game_manager.add_point()
		animation_player.play("pickup")
