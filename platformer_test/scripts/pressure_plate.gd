extends StaticBody2D

@onready var self_node = $"." 

signal pressed 
signal released 

var bodies_on_plate: Array = [] 

func _ready(): 
	self_node.body_entered.connect(_on_body_entered) 
	self_node.body_exited.connect(_on_body_exited) 

func _on_body_entered(body: Node) -> void: 
	bodies_on_plate.append(body) 
	emit_signal("pressed") 

func _on_body_exited(body: Node) -> void: 
	bodies_on_plate.erase(body) 
	if bodies_on_plate.size() == 0: 
		emit_signal("released")
