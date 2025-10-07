extends Control
@onready var game_manager: Node = $".."
@onready var level_0: Button = $CanvasLayer/level0
@onready var level_1: Button = $CanvasLayer/level1
@onready var level_2: Button = $CanvasLayer/level2
var buttons

func _ready() -> void:
	buttons = [level_0, level_1, level_2]

# Called when the node enters the scene tree for the first time.
func set_game_manager(manager: Node):
	# Propagate to children that also have a set_game_manager method
	for button in buttons:
		button.set_game_manager(manager)


func _on_back_button_pressed() -> void:
	game_manager.load_level("res://scenes/start_screen.tscn")
