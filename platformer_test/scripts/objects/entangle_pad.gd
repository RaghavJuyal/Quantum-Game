extends Area2D

@onready var sprite: Sprite2D = $Sprite2D
@onready var self_node: Node = $"."
@onready var game_manager: Node = get_tree().root.get_node("Game/GameManager")
@onready var zone_sound: AudioStreamPlayer2D = $CheckZone

@export var target_00: float = 25
@export var target_01: float = 25
@export var target_10: float = 25
@export var target_11: float = 25
@export var similarity_threshold: float = 0.99
@onready var similarity_label: Label = $Target

var triggered := false
var similarity_shown = false
var normal_color = Color(1.0, 0.55, 0.0, 0.5)

func _ready() -> void:
	sprite.modulate = normal_color
	similarity_label.text = "Target probabilities:\n 00 -> %.2f\n 01 -> %.2f\n 10 -> %.2f\n 11 -> %.2f" % [target_00, target_01, target_10, target_11]
	similarity_shown = false
	z_index = 10

func _process(_delta: float) -> void:
	if not triggered and game_manager.entangled_mode:
		var similarity = compute_similarity()
		if similarity >= similarity_threshold:
			sprite.modulate = Color(0.56, 0.93, 0.56, 0.5)
		else:
			sprite.modulate = normal_color
	elif !game_manager.entangled_mode:
		sprite.modulate = normal_color

func _on_body_entered(body: Node2D) -> void:
	if !game_manager.entangled_mode:
		var state = game_manager.measure()
		Engine.time_scale = 0.5
		game_manager.is_dead = true
		if state == 0:
			body = game_manager.current_level.player
		else:
			body = game_manager.current_level.player_2
		game_manager.schedule_respawn(body)
		return
	
	check_entangled_state(body)	

func compute_similarity() -> float:
	# Bhattacharya coefficient (fidelity)
	var sum = 0.0
	var entangled_probs = game_manager.entangled_probs
	sum = sqrt(entangled_probs[0] * target_00/100.0) + sqrt(entangled_probs[1] * target_01/100.0) + sqrt(entangled_probs[2] * target_10/100.0) + sqrt(entangled_probs[3] * target_11/100.0)	
	var fidelity = sum * sum
	return clamp(fidelity, 0.0, 1.0)  # Ensure it stays in [0, 1]

func check_entangled_state(body: Node2D) -> void:
	var similarity = compute_similarity()
	# since both players enter, we trigger only once
	# we remove the player that didn't trigger if similarity condition fails
	if game_manager.is_dead:
		return
	if triggered:
		if similarity < similarity_threshold:
			game_manager.is_dead = true
		return
	triggered = true
	if !similarity_shown:
		similarity_label.text += "\nSimilarity: %.2f" % (floor(similarity*1000)/1000)
		similarity_shown = true
	else:
		similarity_label.text =  "Target probabilities:\n 00 -> %.2f\n 01 -> %.2f\n 10 -> %.2f\n 11 -> %.2f" % [target_00, target_01, target_10, target_11]
		similarity_label.text += "\nSimilarity: %.2f" % (floor(similarity*1000)/1000)
		similarity_shown = true
		
	if similarity >= similarity_threshold:
		zone_sound.play()
		await zone_sound.finished
		self_node.get_node("CollisionShape2D").queue_free()
		self_node.get_node("Sprite2D").queue_free()
	else:
		# removes check zone if passed, but not the label
		game_manager.measure_entangled()
		Engine.time_scale = 0.5
		game_manager.is_dead = true
		game_manager.schedule_respawn(game_manager.current_level.player)
		triggered = false
