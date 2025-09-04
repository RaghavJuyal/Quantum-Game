extends Area2D

@onready var timer: Timer = $Timer
@onready var game_manager: Node = get_tree().root.get_node("Game/GameManager")


func _on_body_entered(body: Node2D) -> void:
	#print("Death!!!")
	var state = game_manager.measure()
	if (body.is_state_zero and state==0) or (not body.is_state_zero and state == 1):
		Engine.time_scale = 0.5
		body.get_node("CollisionShape2D").queue_free()
		timer.start()
	
	


func _on_timer_timeout() -> void:
	Engine.time_scale = 1
	get_tree().reload_current_scene()
