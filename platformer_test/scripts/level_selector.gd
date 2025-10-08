extends Control
@onready var game_manager: Node = $".."
@onready var level_0: Button = $CanvasLayer/level0
@onready var level_1: Button = $CanvasLayer/level1
@onready var level_2: Button = $CanvasLayer/level2
var buttons
var player_data = {}
var highest_level = 0
func _ready() -> void:
	buttons = [level_0, level_1, level_2]
	var file = "res://scripts/player_data.json"
	load_json(file)
	
	update_level_buttons()

# Called when the node enters the scene tree for the first time.
func set_game_manager(manager: Node):
	# Propagate to children that also have a set_game_manager method
	for button in buttons:
		button.set_game_manager(manager)


func _on_back_button_pressed() -> void:
	game_manager.load_level("res://scenes/start_screen.tscn")
	
	
func load_json(path: String) -> void:
	var parsedResult
	if FileAccess.file_exists(path):
		var f = FileAccess.open(path, FileAccess.READ)
		parsedResult = JSON.parse_string(f.get_as_text())
	else:
		parsedResult = {}
	highest_level = parsedResult["highest_level"]
		


func update_level_buttons():
	for i in range(buttons.size()):
		var button = buttons[i]
		# Assuming your level names are like "level_0", "level_1", etc.
		var level_num = i
		if level_num <= highest_level:
			button.disabled = false
			button.modulate = Color(1,1,1) # normal color
			button.visible = true         # optional if you want to show all
		else:
			button.disabled = true
			button.modulate = Color(0.5,0.5,0.5) # gray out
			#button.visible = false        # alternatively hide locked levels
