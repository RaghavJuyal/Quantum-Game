extends Area2D

@onready var game_manager: Node = get_tree().root.get_node("Game/GameManager")
@onready var finish_sound: AudioStreamPlayer2D = $Finish_sound
var highest_level
signal finished_level
var parsedResult
func _on_body_entered(_body: Node2D) -> void:
	var measured_state = null
	if !game_manager.entangled_mode:
		measured_state = game_manager.measure()
	else:
		measured_state = game_manager.measure_entangled()
	var file_path = "user://player_data.json"
	load_json(file_path)
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
			var save_file = FileAccess.open(file_path, FileAccess.WRITE)
			if save_file:
				save_file.store_string(JSON.stringify(parsedResult," "))
				save_file.close()
	#finish_sound.play()
	#await finish_sound.finished
	
	emit_signal("finished_level")

func load_json(path: String) -> void:
	if FileAccess.file_exists(path):
		var f = FileAccess.open(path, FileAccess.READ)
		parsedResult = JSON.parse_string(f.get_as_text())
	else:
		parsedResult = {}
	highest_level = parsedResult["highest_level"]
