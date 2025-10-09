extends Node3D

@onready var sphere: MeshInstance3D = $Sphere
@onready var arrow: MeshInstance3D = $Wrapper/Arrow
@onready var wrapper: Node3D = $Wrapper
@onready var game_manager: Node = get_tree().root.get_node("Game/GameManager")

func _ready():
	# Orient wrapper so Z is vertical (up)
	wrapper.rotation_degrees = Vector3(0, 0, 0)

	# Sphere material (translucent light blue)
	var sphere_mat = StandardMaterial3D.new()
	sphere_mat.albedo_color = Color(0.4, 0.7, 1.0)
	sphere_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	sphere_mat.albedo_color.a = 0.2
	sphere_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	sphere.material_override = sphere_mat

	# Add thick axes using cylinders
	_add_axis(Vector3(1, 0, 0), Color(1.0, 0.4, 0.4), "X Axis")   # X → red
	_add_axis(Vector3(0, 0, 1), Color(0.5, 1.0, 0.5), "Y Axis")  # Y → green
	_add_axis(Vector3(0, 1, 0), Color(0.4, 0.6, 1.0), "Z Axis") # Z → blue (up)

	# Add a light for soft shading (optional)
	var light = DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-45, 45, 0)
	add_child(light)

	var arrow_mat = StandardMaterial3D.new()
	arrow_mat.albedo_color = Color(0, 0, 0)
	arrow.material_override = arrow_mat
	# Position arrow so it rotates around its base
	arrow.position = Vector3(0, 0.125, 0)
	for child in arrow.get_children():
		child.position = Vector3(0, 0.125, 0)  # move the tip forward
		child.material_override = arrow_mat

	# Camera setup — angled so all 3 axes visible
	var cam = $Camera3D
	cam.position = Vector3(1.5, 1, 3)
	cam.look_at(Vector3.ZERO)

func _add_axis(direction: Vector3, color: Color, name: String):
	var axis = MeshInstance3D.new()
	axis.name = name

	var cyl = CylinderMesh.new()
	cyl.height = 0.60
	cyl.top_radius = 0.01
	cyl.bottom_radius = 0.01
	axis.mesh = cyl

	var mat = StandardMaterial3D.new()
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.albedo_color = color
	axis.material_override = mat

	# Align cylinder along desired direction
	if direction == Vector3(1, 0, 0):  # X axis
		axis.rotation_degrees = Vector3(0, 0, 90)
	elif direction == Vector3(0, 0, 1):  # Y axis
		axis.rotation_degrees = Vector3(90, 0, 0)
	else:
		axis.rotation_degrees = Vector3(0, 0, 0)  # Z axis

	add_child(axis)

func _process(delta):
	if game_manager == null:
		return

	# Reset / Measurement logic
	if game_manager.state == 0:
		# |0> → point up (Z+)
		wrapper.rotation = Vector3(0, 0, 0)
	elif game_manager.state == 1:
		# |1> → point down (Z-)
		wrapper.rotation = Vector3(PI, 0, 0)
	elif game_manager.suppos_allowed:
		# X rotation
		if Input.is_action_pressed("x_rotation"):
			wrapper.rotate_x(game_manager.delta_theta)
		# Y rotation
		if Input.is_action_pressed("y_rotation"):
			wrapper.rotate_z(-game_manager.delta_theta)
		# Z rotation
		if Input.is_action_pressed("z_rotation"):
			wrapper.rotate_y(game_manager.delta_theta)

func _rotate_x(angle: float):
	wrapper.rotate_x(angle)
func _rotate_y(angle:float):
	wrapper.rotate_y(angle)
func _rotate_z(angle:float):
	wrapper.rotate_z(angle)
