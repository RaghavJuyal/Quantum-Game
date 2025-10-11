extends Button

var filepath
var game_manager

func _ready() -> void:
	#self.text = self.name
	filepath = "res://scenes/" + str(self.name) + ".tscn"

func _on_button_pressed() -> void:
	game_manager.next_file_path = filepath
	game_manager.current_level_name = self.name
	game_manager.load_level("res://scenes/loading_screen.tscn")

func set_game_manager(manager):
	game_manager = manager
