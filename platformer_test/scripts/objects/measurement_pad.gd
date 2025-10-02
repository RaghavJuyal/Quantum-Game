extends Area2D

@onready var game_manager: Node = get_tree().root.get_node("Game/GameManager")
@onready var player: CharacterBody2D = $"../../Player"
@onready var player_2: CharacterBody2D = $"../../Player2"

func _on_body_entered(body: Node2D) -> void:
	game_manager.checkpoint_player = body
	game_manager.checkpoint_position_0 = player.global_position
	game_manager.checkpoint_position_1 = player_2.global_position
	if !game_manager.entangled_mode:
		game_manager.measure()
	else:
		game_manager.measure_entangled()
