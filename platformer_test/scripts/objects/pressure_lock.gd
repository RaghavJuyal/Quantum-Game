extends RigidBody2D

@onready var sprite: Sprite2D = $Sprite2D
@onready var collider: CollisionShape2D = $WallCollider

func _ready() -> void:
	sprite.modulate = Color(0.60, 0.40, 0.20, 1.0)

func open():
	visible = false
	collider.call_deferred("set", "disabled", true)

func close():
	visible = true
	collider.call_deferred("set", "disabled", false)
