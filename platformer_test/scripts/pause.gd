extends CanvasLayer
@onready var button: Button = $Panel/Button
@onready var game_manager: Node = $".."
@onready var panel: Panel = $Panel/Panel

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED

func _on_button_pressed() -> void:
	self.visible = false
	get_tree().paused = false

func _on_quit_button_pressed() -> void:
	self.visible = false
	get_tree().paused = false
	game_manager.progress_reset()
	game_manager.load_level("res://scenes/start_screen.tscn")
