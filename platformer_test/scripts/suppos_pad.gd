extends Area2D

@onready var sprite: Sprite2D = $Sprite2D
@onready var game_manager: Node = %GameManager

@export var target_theta: float = PI / 2   # example target = |+>
@export var target_phi: float = 0.0
@export var fidelity_threshold: float = 0.9

func _ready() -> void:
	sprite.modulate = Color(0.7, 0.3, 0.9, 0.5)

func _on_body_entered(body: Node2D) -> void:
	print("entered zone")
	var fidelity = game_manager.compute_fidelity(target_theta, target_phi)
	print("fidelity was "+str(fidelity))
	if fidelity >= fidelity_threshold:
		game_manager.add_point()
	else:
		var state = game_manager.measure()
		if (body.is_state_zero and state==0) or (not body.is_state_zero and state == 1):
			Engine.time_scale = 0.5
			body.get_node("CollisionShape2D").queue_free()
			game_manager.schedule_respawn()
		else:
			game_manager.remove_point()
