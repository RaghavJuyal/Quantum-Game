extends CanvasLayer
@onready var button: Button = $Panel/Button
@onready var game_manager: Node = $".."

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED

#func _process(delta: float) -> void:
	##if Input.is_action_just_pressed("pause"):
##		get_tree().paused = false
##		print("passed here")
	#if get_tree().paused == true:
		#self.visible = true

func _on_button_pressed() -> void:
	self.visible = false
	get_tree().paused = false


func _on_quit_button_pressed() -> void:
	
	#print(game_manager.current_level)
	self.visible = false
	get_tree().paused = false
	game_manager.load_level("res://scenes/start_screen.tscn")
