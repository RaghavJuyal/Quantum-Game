extends Area2D

@onready var game_manager: Node = %GameManager
@onready var finish_sound: AudioStreamPlayer2D = $Finish_sound

func _on_body_entered(body: Node2D) -> void:
	var measured_state = null
	if !game_manager.entangled_mode:
		measured_state = game_manager.measure()
	else:
		measured_state = game_manager.measure_entangled()
