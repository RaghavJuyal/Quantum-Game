extends Area2D

@onready var game_manager: Node = get_tree().root.get_node("Game/GameManager")
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	if self.name in game_manager.coins_picked_up:
		queue_free()
		return

func _on_body_entered(body: Node2D) -> void:
	# Measure on interaction with the coin and add point
	var measured_state = null
	if !game_manager.entangled_mode:
		measured_state = game_manager.measure()
	else:
		measured_state = game_manager.measure_entangled()
	if (body.is_state_zero and measured_state == 0) or (not body.is_state_zero and measured_state == 1):
		game_manager.add_point(self.name)
		animation_player.play("pickup")
