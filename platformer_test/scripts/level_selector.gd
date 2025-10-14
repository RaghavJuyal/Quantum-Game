extends Control

@onready var game_manager: Node = $".."
@onready var level_0: Button = $CanvasLayer/level0
@onready var level_1: Button = $CanvasLayer/level1
@onready var level_2: Button = $CanvasLayer/level2
@onready var challengelevel: Button = $CanvasLayer/challengelevel

var buttons
var player_data = {}
var highest_level = 0
var player_data_path = "user://player_data.json"

func _ready() -> void:
	buttons = [level_0, level_1, level_2, challengelevel]
	var parsed = load_json()
	if typeof(parsed) == TYPE_DICTIONARY and "highest_level" in parsed:
		highest_level = parsed["highest_level"]
	else:
		highest_level = 0
	
	update_level_buttons()

func set_game_manager(manager: Node):
	for button in buttons:
		if "set_game_manager" in button:
			button.set_game_manager(manager)

func _on_back_button_pressed() -> void:
	game_manager.load_level("res://scenes/start_screen.tscn")

func load_json():
	var parsedResult
	if FileAccess.file_exists(player_data_path):
		var f = FileAccess.open(player_data_path, FileAccess.READ)
		parsedResult = JSON.parse_string(f.get_as_text())
		f.close()
	else:
		parsedResult = {}
		# initialize a default structure if no file exists
		parsedResult = {
			"highest_level": 0.0,
			"highscore": [
				{
					"level0": 0.0
				},
				{
					"level1": 0.0
				},
				{
					"level2": 0.0
				},
				{
					"challengelevel": 0.0
				}
			]
		}
		save_json(parsedResult)
	return parsedResult

func save_json(parsedResult):
	var f = FileAccess.open(player_data_path, FileAccess.WRITE)
	f.store_string(JSON.stringify(parsedResult, "  "))
	f.close()

func update_level_buttons() -> void:
	for button in buttons:
		match button.name:
			"level0":
				button.disabled = false
				button.modulate = Color(1, 1, 1)
			"level1":
				button.disabled = highest_level < 1
				button.modulate = Color(0.5, 0.5, 0.5) if button.disabled else Color(1, 1, 1)
			"level2":
				button.disabled = highest_level < 2
				button.modulate = Color(0.5, 0.5, 0.5) if button.disabled else Color(1, 1, 1)
			"challengelevel":
				button.disabled = highest_level < 3
				button.modulate = Color(0.5, 0.5, 0.5) if button.disabled else Color(1, 1, 1)

func _on_highscores_pressed() -> void:
	game_manager.load_level("res://scenes/highscores.tscn")
