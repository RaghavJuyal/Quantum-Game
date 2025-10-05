extends CanvasLayer
@onready var button: Button = $Panel/Button

func _process(delta: float) -> void:
	#if Input.is_action_just_pressed("pause"):
#		get_tree().paused = false
#		print("passed here")
	if get_tree().paused == true:
		self.visible = true

func _on_button_pressed() -> void:
	self.visible = false
	get_tree().paused = false


func _on_quit_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/start_screen.tscn")
