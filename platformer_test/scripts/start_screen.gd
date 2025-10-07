extends Control
const selector_scene = "res://scenes/level_selector.tscn"
const settings_scene = "res://scenes/settings_screen.tscn"
var game_manager: Node = null

func _ready() -> void:
	get_tree().paused = false

func _on_start_button_pressed() -> void:
	game_manager.progress_reset()
	game_manager.load_level(selector_scene)

func _on_settings_button_pressed() -> void:
	game_manager.load_level(settings_scene)

func _on_quit_button_pressed() -> void:
	get_tree().quit()

func set_game_manager(manager: Node):
	game_manager = manager
