extends Control

var game_manager: Node = null
var parsedResult

@onready var level_0_score: Label = $CanvasLayer/level0score
@onready var level_0_hardscore: Label = $CanvasLayer/level0hardscore
@onready var level_1_score: Label = $CanvasLayer/level1score
@onready var level_1_hardscore: Label = $CanvasLayer/level1hardscore
@onready var level_2_score: Label = $CanvasLayer/level2score
@onready var level_2_hardscore: Label = $CanvasLayer/level2hardscore

func set_game_manager(manager: Node):
	game_manager = manager

func _ready() -> void:
	load_json("user://player_data.json")

	# Keep labels in order matching JSON array
	var score_labels = [
		level_0_score, level_1_score, level_2_score,
		level_0_hardscore, level_1_hardscore, level_2_hardscore
	]

	if "highscore" in parsedResult:
		for i in range(parsedResult["highscore"].size()):
			var level_entry = parsedResult["highscore"][i]
			var level_name = level_entry.keys()[0]
			var score_value = level_entry[level_name]
			if i < score_labels.size():
				score_labels[i].text = "%.2f" % score_value
	else:
		print("⚠️ No 'highscore' key found in player_data.json")

func _on_level_select_pressed() -> void:
	game_manager.load_level("res://scenes/level_selector.tscn")

func load_json(path: String):
	if FileAccess.file_exists(path):
		var f = FileAccess.open(path, FileAccess.READ)
		parsedResult = JSON.parse_string(f.get_as_text())
		f.close()
	else:
		# initialize a default structure if no file exists
		parsedResult = {
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
