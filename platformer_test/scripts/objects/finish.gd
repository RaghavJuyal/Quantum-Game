extends Area2D

@onready var game_manager: Node = get_tree().root.get_node("Game/GameManager")
@onready var finish_sound: AudioStreamPlayer2D = $Finish_sound
var parsedResult
var highest_level
signal finished_level

func _on_body_entered(_body: Node2D) -> void:
	var measured_state = null
	if !game_manager.entangled_mode:
		measured_state = game_manager.measure()
	else:
		measured_state = game_manager.measure_entangled()
	
	game_manager.load_json()
	highest_level = parsedResult["highest_level"]
	var level_name = game_manager.current_level_name
	var match = level_name.match("\\d+")
	var level_index = 0
	
	if level_name.begins_with("level"):
		level_index = int(level_name.substr(5, level_name.length() - 5))  # skip "level"
		# Load JSON safely
		# Update highest_level only if completed level is >= current highest_level
		if level_index >= highest_level:
			parsedResult["highest_level"] = int(level_index + 1)  # unlock next level

			# Save JSON back to file
			game_manager.save_json(parsedResult)
	
	emit_signal("finished_level")
