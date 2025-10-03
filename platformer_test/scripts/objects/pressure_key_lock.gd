extends Node2D
@onready var pressure_lock: RigidBody2D = $PressureLock
@onready var pressure_plate: RigidBody2D = $PressurePlate


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pressure_plate.get_node("Area2D").pressed.connect(pressure_lock.open)
	pressure_plate.get_node("Area2D").released.connect(pressure_lock.close)
