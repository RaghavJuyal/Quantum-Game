extends Area2D

var is_state_zero = false
@onready var ent_space: Sprite2D = $EntSpace

func _ready():
	ent_space.modulate = Color(1, 0.69, 0, 0.4)
