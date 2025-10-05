extends Control
const selector_scene = "res://scenes/level_selector.tscn"
const settings_scene = "res://scenes/settings_screen.tscn"

func _ready() -> void:
	get_tree().paused = false

func _on_start_button_pressed() -> void:
	
	get_tree().change_scene_to_file(selector_scene)


func _on_settings_button_pressed() -> void:
	get_tree().change_scene_to_file(settings_scene)


func _on_quit_button_pressed() -> void:
	get_tree().quit()
