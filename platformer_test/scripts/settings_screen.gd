extends Control
@onready var game_manager: Node = $".."
@onready var h_slider: HSlider = $CanvasLayer/Panel/HSlider
@onready var button: Button = $CanvasLayer/Button


func set_game_manager(manager: Node):
	# Propagate to children that also have a set_game_manager method
	h_slider.set_game_manager(manager)


func _on_button_pressed() -> void:
	game_manager.load_level("res://scenes/start_screen.tscn")
