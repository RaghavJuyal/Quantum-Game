extends Control

@onready var game_manager: Node = $".."
@onready var level_0: Button = $CanvasLayer/level0
@onready var level_1: Button = $CanvasLayer/level1
@onready var level_2: Button = $CanvasLayer/level2
@onready var challengelevel: Button = $CanvasLayer/challengelevel

var buttons
var player_data = {}
var highest_level = 0

func _ready() -> void:
	buttons = [level_0, level_1, level_2, challengelevel]
	load_json("res://scripts/player_data.json")
	update_level_buttons()

func set_game_manager(manager: Node):
	for button in buttons:
		if "set_game_manager" in button:
			button.set_game_manager(manager)

func _on_back_button_pressed() -> void:
	game_manager.load_level("res://scenes/start_screen.tscn")

func load_json(path: String) -> void:
	if FileAccess.file_exists(path):
		var f = FileAccess.open(path, FileAccess.READ)
		var parsed = JSON.parse_string(f.get_as_text())
		if typeof(parsed) == TYPE_DICTIONARY and "highest_level" in parsed:
			highest_level = parsed["highest_level"]
		else:
			highest_level = 0
	else:
		highest_level = 0

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
