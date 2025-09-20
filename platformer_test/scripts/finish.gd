extends Area2D

@onready var game_manager: Node = %GameManager
@onready var finish_sound: AudioStreamPlayer2D = $Finish_sound

func _on_body_entered(body: Node2D) -> void:
	var state = game_manager.measure()
	finish_sound.play()
