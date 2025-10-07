extends Control
@onready var h_slider: HSlider = $CanvasLayer/Panel/HSlider

func set_game_manager(manager: Node):
	# Propagate to children that also have a set_game_manager method
	h_slider.set_game_manager(manager)
