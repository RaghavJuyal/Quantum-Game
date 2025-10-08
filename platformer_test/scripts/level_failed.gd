extends CanvasLayer

@onready var game_manager: Node = $".."

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	#self.visible = false



func _on_try_again_pressed() -> void:
	self.visible = false
	get_tree().paused = false
	game_manager.load_level(game_manager.current_level_path)


func _on_main_menu_pressed() -> void:
	self.visible = false
	get_tree().paused = false
	game_manager.load_level("res://scenes/start_screen.tscn")
	#pass # Replace with function body.
