extends Node3D

@onready var sphere: MeshInstance3D = $Sphere
@onready var arrow: MeshInstance3D = $Arrow
@onready var x_axis: MeshInstance3D = $"X Axis"
@onready var y_axis: MeshInstance3D = $"Y Axis"
@onready var z_axis: MeshInstance3D = $"Z Axis"

var game_manager

func _ready():
	# Slightly transparent sphere for visibility
	var sphere_mat = StandardMaterial3D.new()
	sphere_mat.albedo_color = Color(0.4, 0.7, 1.0, 0.2)
	sphere_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	sphere.material_override = sphere_mat

	# Axes materials
	_make_axis(x_axis, Color.RED)
	_make_axis(y_axis, Color.GREEN)
	_make_axis(z_axis, Color.BLUE)

	# Position arrow so it rotates around its base
	arrow.position = Vector3(0, 0, 0)
	for child in arrow.get_children():
		child.position = Vector3(0, 0, 0.5)  # arrow tip forward

	# Camera setup
	var cam = $Camera3D
	cam.position = Vector3(2.5, 1.5, 2.5)
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
