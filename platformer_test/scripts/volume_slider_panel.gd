extends Panel
@onready var h_slider: HSlider = $HSlider


func _update_from_audio_bus() -> void:
	h_slider._update_from_audio_bus()
