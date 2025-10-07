extends Area2D

signal pressed
signal released

@onready var pressure_plate: RigidBody2D = $".."
var bodies_on_plate: Array = []

func _ready() -> void:
	pressure_plate.add_to_group("pressure_plate")

func _on_body_entered(body: Node) -> void:
	if body == pressure_plate:
		return
	bodies_on_plate.append(body)
	emit_signal("pressed")

func _on_body_exited(body: Node) -> void:
	if body == pressure_plate:
		return
	bodies_on_plate.erase(body)
	if bodies_on_plate.is_empty():
		emit_signal("released")
