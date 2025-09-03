extends MeshInstance3D
@onready var arrow: MeshInstance3D = $"."
@onready var game_manager: Node = get_tree().root.get_node("Game/GameManager")



func _process(delta):
	# X Rotation 
	if Input.is_action_pressed("x_rotation"):
		arrow.rotate_x(game_manager.delta_theta)
	
	# Y Rotation
	if Input.is_action_just_pressed("y_rotation"):
		arrow.rotate_z(deg_to_rad(-15)) # rotate 15° about Y
	
	# Z Rotation
	if Input.is_action_just_pressed("z_rotation"):
		arrow.rotate_y(deg_to_rad(15)) # rotate 15° about Z
