extends MeshInstance3D
@onready var arrow: MeshInstance3D = $"."
@onready var game_manager: Node = %GameManager



func _process(delta):
	if Input.is_action_pressed("x_rotation"):
		#arrow.rotate_x(game_manager.theta)
		arrow.rotate_x(deg_to_rad(15)) # rotate 15° about X
	if Input.is_action_just_pressed("y_rotation"):
		arrow.rotate_z(deg_to_rad(-15)) # rotate 15° about Y
	if Input.is_action_just_pressed("z_rotation"):
		arrow.rotate_y(deg_to_rad(15)) # rotate 15° about Z
