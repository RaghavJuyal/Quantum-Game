extends Node3D

@onready var sphere: MeshInstance3D = $Sphere
@onready var arrow: MeshInstance3D = $Wrapper/Arrow
@onready var x_axis: MeshInstance3D = $"X Axis"
@onready var y_axis: MeshInstance3D = $"Y Axis"
@onready var z_axis: MeshInstance3D = $"Z Axis"
@onready var wrapper: Node3D = $Wrapper

@onready var game_manager: Node = get_tree().root.get_node("Game/GameManager")

func _ready():
	wrapper.rotation_degrees = Vector3(-90, 0, 0)
	
	var sphere_mat = StandardMaterial3D.new()
	sphere_mat.albedo_color = Color(0.4, 0.7, 1.0, 0.2)
	sphere_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	sphere.material_override = sphere_mat
	
	var axis_mesh = ImmediateMesh.new()
	axis_mesh.surface_begin(Mesh.PRIMITIVE_LINES)

	# X-axis (red)
	axis_mesh.surface_set_color(Color.RED)
	axis_mesh.surface_add_vertex(Vector3.ZERO)
	axis_mesh.surface_add_vertex(Vector3(0.5, 0, 0))

	# Y-axis (green)
	axis_mesh.surface_set_color(Color.GREEN)
	axis_mesh.surface_add_vertex(Vector3.ZERO)
	axis_mesh.surface_add_vertex(Vector3(0, 0.5, 0))

	# Z-axis (blue)
	axis_mesh.surface_set_color(Color.BLUE)
	axis_mesh.surface_add_vertex(Vector3.ZERO)
	axis_mesh.surface_add_vertex(Vector3(0, 0, 0.75))

	axis_mesh.surface_end()

	# Create a MeshInstance3D to hold it
	var axis_instance = MeshInstance3D.new()
	axis_instance.mesh = axis_mesh

	# Make it unshaded so colors are visible regardless of lighting
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.vertex_color_use_as_albedo = true
	axis_instance.material_override = mat

	add_child(axis_instance)
	
	var light = DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-45, 45, 0)
	add_child(light)

	# Position arrow so it rotates around its base
	arrow.position = Vector3(0, 0, 0)
	for child in arrow.get_children():
		child.position = Vector3(0, 0.25, 0)  # arrow tip forward

	# Camera setup
	var cam = $Camera3D
	cam.position = Vector3(1.5, 1, 2)
	cam.look_at(Vector3.ZERO)

func _make_axis(axis_node: MeshInstance3D, color: Color):
	var mat = StandardMaterial3D.new()
	mat.albedo_color = color
	axis_node.material_override = mat

func _process(delta):
	if game_manager == null:
		return

	if game_manager.state == 0:
		arrow.rotation = Vector3(0, -PI/2.0, -PI/2.0)
	elif game_manager.state == 1:
		arrow.rotation = Vector3(PI, -PI/2.0, -PI/2.0)
	elif game_manager.suppos_allowed:
		if Input.is_action_pressed("x_rotation"):
			arrow.rotate_x(game_manager.delta_theta)
		if Input.is_action_pressed("y_rotation"):
			arrow.rotate_z(-game_manager.delta_theta)
		if Input.is_action_pressed("z_rotation"):
			arrow.rotate_y(game_manager.delta_theta)
