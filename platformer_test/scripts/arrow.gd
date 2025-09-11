extends MeshInstance3D

@onready var arrow: MeshInstance3D = $"."
@onready var game_manager: Node = get_tree().root.get_node("Game/GameManager")

func _process(delta):
	if game_manager.state==0:
		arrow.rotation = Vector3(0,-PI/2.0,-PI/2.0)
	elif game_manager.state ==1:
		arrow.rotation = Vector3(PI,-PI/2.0,-PI/2.0)
	elif game_manager.allowed:
		# X Rotation 
		if Input.is_action_pressed("x_rotation"):
			arrow.rotate_x(game_manager.delta_theta)
		
		# Y Rotation
		if Input.is_action_pressed("y_rotation"):
			arrow.rotate_z(-game_manager.delta_theta)
		
		# Z Rotation
		if Input.is_action_pressed("z_rotation"):
			arrow.rotate_y(game_manager.delta_theta) 
