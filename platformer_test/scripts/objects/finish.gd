extends Area2D

@onready var game_manager: Node = get_tree().root.get_node("Game/GameManager")
@onready var finish_sound: AudioStreamPlayer2D = $Finish_sound

signal finished_level

func _on_body_entered(_body: Node2D) -> void:
	var measured_state = null
	if !game_manager.entangled_mode:
		measured_state = game_manager.measure()
	else:
		measured_state = game_manager.measure_entangled()
	finish_sound.play()
	await finish_sound.finished
	emit_signal("finished_level")
