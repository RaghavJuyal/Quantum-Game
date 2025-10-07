extends Area2D

@onready var sprite: Sprite2D = $Sprite2D
@onready var self_node: Node = $"."
@onready var game_manager: Node = get_tree().root.get_node("Game/GameManager")
@onready var zone_sound: AudioStreamPlayer2D = $CheckZone

@export var target_theta: float = PI / 2
@export var target_phi: float = 0.0
@export var fidelity_threshold: float = 0.99
@onready var fidelity_label: Label = $Target

var triggered := false
var fidelity_shown = false

func _ready() -> void:
	sprite.modulate = Color(0.7, 0.3, 0.9, 0.5)
	fidelity_label.text = "Target state:\nθ = %.2f, φ = %.2f" % [round(rad_to_deg(target_theta)*10)/10, round(rad_to_deg(target_phi)*10)/10]
	fidelity_shown = false

func _on_body_entered(body: Node2D) -> void:
	if game_manager.entangled_mode:
		return
	var fidelity = game_manager.compute_fidelity(target_theta, target_phi)
	# since both players enter, we trigger only once
	# we remove the player that didn't trigger if fidelity condition fails
	if game_manager.is_dead:
		return
	if triggered:
		if fidelity < fidelity_threshold:
			game_manager.schedule_respawn(body)
			game_manager.is_dead = true
		return
	triggered = true
	if !fidelity_shown:
		fidelity_label.text += "\nFidelity: %.2f" % (round(fidelity*1000)/1000)
		fidelity_shown = true
	else:
		fidelity_label.text = "Target state:\nθ = %.2f, φ = %.2f" % [round(rad_to_deg(target_theta)*10)/10, round(rad_to_deg(target_phi)*10)/10]
		fidelity_label.text += "\nFidelity: %.2f" % (round(fidelity*1000)/1000)
		fidelity_shown = true
		
	if fidelity >= fidelity_threshold:
		zone_sound.play()
		await zone_sound.finished
		self_node.get_node("CollisionShape2D").queue_free()
		self_node.get_node("Sprite2D").queue_free()
	else:
		game_manager.set_state_zero()
		Engine.time_scale = 0.5
		game_manager.is_dead = true
		game_manager.schedule_respawn(body)
		triggered = false
	# removes check zone if passed, but not the label
