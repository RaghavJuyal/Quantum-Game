extends Area2D
var interacting = false
var index = 0

func _ready() -> void:
	pass
	
func _on_body_entered(body: Node2D) -> void:
	index = 0
	interacting = true
	
func _on_body_exit(body: Node2D) -> void:
	interacting = false

func _process(delta: float) -> void:
	if interacting:
		if Input.is_action_just_pressed("ui_accept"):
			index += 1
