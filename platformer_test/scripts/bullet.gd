extends Node2D   

const SPEED = 100
var direction = -1

@onready var ray_cast_right: RayCast2D = $RayCastRight
@onready var ray_cast_left: RayCast2D = $RayCastLeft

func _process(delta: float) -> void:
	position.x += direction * SPEED * delta

	if position.x < -2000 or position.x > 2000:
		queue_free()
	
	# Remove bullet when it collides with the wall
	if ray_cast_right.is_colliding():
		queue_free()
	
	if ray_cast_left.is_colliding():
		queue_free()
