extends Area2D
var interacting = false
var index = 0
@onready var text_edit: TextEdit = $"../../Textcontainer/texts/TextEdit"
@onready var game_manager: Node = get_tree().root.get_node("Game/GameManager")


func _ready() -> void:
	pass
	
func _on_body_entered(body: Node2D) -> void:
	var measured_state = null
	if !game_manager.entangled_mode:
		measured_state = game_manager.measure()
	else:
		measured_state = game_manager.measure_entangled()
	if (body.is_state_zero and measured_state == 0) or (not body.is_state_zero and measured_state == 1):
		index = 0
		interacting = true
		text_edit.visible = true
		game_manager.Stopper()
		text_edit.dialogreader(self.name, index)
	
func _on_body_exit(body: Node2D) -> void:
	index = 0
	interacting = false
	text_edit.visible = false

func _process(delta: float) -> void:
	if interacting:
		if Input.is_action_just_pressed("ui_accept"):
			index += 1
			if len(text_edit.parsedResult[self.name]) <= index:
				interacting = false
				game_manager.Starter()
				text_edit.visible = false
			else:
				text_edit.dialogreader(self.name, index)
