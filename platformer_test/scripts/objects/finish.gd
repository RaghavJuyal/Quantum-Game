extends Area2D

signal finished_level
@onready var game_manager: Node = get_tree().root.get_node("Game/GameManager")
@onready var finish_sound: AudioStreamPlayer2D = $Finish_sound

func _on_body_entered(_body: Node2D) -> void:
	var measured_state = null
	if !game_manager.entangled_mode:
		measured_state = game_manager.measure()
	else:
		measured_state = game_manager.measure_entangled()
	finish_sound.play()
	emit_signal("finished_level")
