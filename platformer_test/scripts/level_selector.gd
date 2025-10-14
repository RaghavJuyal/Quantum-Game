extends Control

@onready var game_manager: Node = $".."
@onready var level_0: Button = $CanvasLayer/level0
@onready var level_1: Button = $CanvasLayer/level1
@onready var level_2: Button = $CanvasLayer/level2
@onready var level_0hard: Button = $CanvasLayer/level0hard
@onready var level_1hard: Button = $CanvasLayer/level1hard
@onready var level_2hard: Button = $CanvasLayer/level2hard

var buttons
var player_data = {}
var highest_level = 0

func _ready() -> void:
	buttons = [level_0, level_1, level_2, level_0hard, level_1hard, level_2hard]
	var file = "user://player_data.json"
	load_json(file)
	update_level_buttons()

func set_game_manager(manager: Node):
	for button in buttons:
		if "set_game_manager" in button:
			button.set_game_manager(manager)

func _on_back_button_pressed() -> void:
	game_manager.load_level("res://scenes/start_screen.tscn")

func load_json(path: String):
	if FileAccess.file_exists(path):
		var f = FileAccess.open(path, FileAccess.READ)
		var parsedResult = JSON.parse_string(f.get_as_text())
		if typeof(parsedResult) == TYPE_DICTIONARY and "highest_level" in parsedResult:
			highest_level = parsedResult["highest_level"]
		else:
			highest_level = 0
		f.close()
	else:
		highest_level = 0
		# initialize a default structure if no file exists
		var parsedResult = {
			"highest_level": 0,
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
				"level0hard": 0.0
				},
				{
				"level1hard": 0.0
				},
				{
				"level2hard": 0.0
				}
			]
		}
		save_json(path, parsedResult)

func save_json(path: String, parsedResult):
	var f = FileAccess.open(path, FileAccess.WRITE)
	f.store_string(JSON.stringify(parsedResult, "  "))
	f.close()

func update_level_buttons() -> void:
	for i in range(buttons.size()):
		var button = buttons[i]
		var is_hard = button.name.ends_with("hard")
		var level_num = int(button.name.replace("level", "").replace("hard", ""))

		# Unlock condition
		if (not is_hard and highest_level >= level_num) or (is_hard and highest_level > level_num):
			button.disabled = false
			button.modulate = Color(1, 1, 1)
		else:
			button.disabled = true
			button.modulate = Color(0.5, 0.5, 0.5)


func _on_highscores_pressed() -> void:
	game_manager.load_level("res://scenes/highscores.tscn")
