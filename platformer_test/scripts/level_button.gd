extends Button

var filepath

func _ready() -> void:
	self.text = self.name
	var loading_scene = preload("res://scenes/loading_screen.tscn").instantiate()
	filepath = "res://scenes/"+str(self.name)+".tscn"


func _on_button_pressed() -> void:
	var loading_scene = preload("res://scenes/loading_screen.tscn").instantiate()
	loading_scene.target_scene_path = filepath
	get_tree().root.add_child(loading_scene)
	get_tree().current_scene.queue_free()
	get_tree().current_scene = loading_scene
