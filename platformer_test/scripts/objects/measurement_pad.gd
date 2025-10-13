extends Area2D

@onready var game_manager: Node = get_tree().root.get_node("Game/GameManager")
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var player: CharacterBody2D = $"../../Player"
@onready var player_2: CharacterBody2D = $"../../Player2"
var played_sound = false

func _on_body_entered(body: Node2D) -> void:
	game_manager.checkpoint_player_zero = body.is_state_zero
	game_manager.checkpoint_position_0 = player.global_position
	game_manager.checkpoint_position_1 = player_2.global_position
	
	if !played_sound:
		played_sound = true
		sprite_2d.modulate = Color(0.4, 1.0, 0.4, 0.8) # bright soft green, slightly transparent
		sprite_2d.scale = Vector2(1.2, 1.2)
		sprite_2d.create_tween().tween_property(sprite_2d, "scale", Vector2.ONE, 0.3).set_trans(Tween.TRANS_BACK)
		
		var sound_player = game_manager.get_node_or_null("Checkpoint")
		if sound_player and not sound_player.playing:
			sound_player.play()
	
	if !game_manager.entangled_mode:
		game_manager.measure()
	else:
		game_manager.measure_entangled()
