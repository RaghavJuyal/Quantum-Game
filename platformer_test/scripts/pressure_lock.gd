extends StaticBody2D

@onready var sprite: Sprite2D = $Sprite2D
@onready var collider: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	sprite.modulate = Color(0.60, 0.40, 0.20, 1.0)

func open():
	visible = false
	collider.disabled = true

func close():
	visible = true
	collider.disabled = false
