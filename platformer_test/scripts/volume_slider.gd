extends HSlider

@export var audio_bus_name := "Master"

@onready var label: Label = $Label
@onready var _bus := AudioServer.get_bus_index(audio_bus_name)


func _ready() -> void:
	value = db_to_linear(AudioServer.get_bus_volume_db(_bus))
	label.text = str(int(10*self.value))


func _on_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(_bus, linear_to_db(value))
	label.text = str(int(10*self.value))


func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/start_screen.tscn")
