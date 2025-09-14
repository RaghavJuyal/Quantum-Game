extends Area2D

@onready var sprite: Sprite2D = $Sprite2D
@onready var self_node: Node = $"."
@onready var game_manager: Node = %GameManager
@onready var coin_pick_sound: AudioStreamPlayer2D = $pickupsound

@export var target_theta: float = PI / 2
@export var target_phi: float = 0.0
@export var fidelity_threshold: float = 0.95
@onready var fidelity_label: Label = $Target

var triggered := false

func _ready() -> void:
	sprite.modulate = Color(0.7, 0.3, 0.9, 0.5)
	fidelity_label.text = "Target state:\nθ = %.2f, φ = %.2f" % [round(rad_to_deg(target_theta)*10)/10, round(rad_to_deg(target_phi)*10)/10]

func _on_body_entered(body: Node2D) -> void:
	if triggered:
		return
	triggered = true
	var fidelity = game_manager.compute_fidelity(target_theta, target_phi)
	fidelity_label.text += "\nFidelity: %.2f" % (round(fidelity*1000)/1000)
	if fidelity >= fidelity_threshold:
		game_manager.add_point()
		coin_pick_sound.play()
		await coin_pick_sound.finished
	else:
		game_manager.set_state_zero()
		Engine.time_scale = 0.5
		body.get_node("CollisionShape2D").queue_free()
		game_manager.schedule_respawn()
	self_node.get_node("CollisionShape2D").queue_free()
	self_node.get_node("Sprite2D").queue_free()
