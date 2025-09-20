extends Node

var score = 0
var theta = 0
var phi = 0
var delta_theta = 0
var bloch_vec: Vector3 = Vector3(0, 0, 1)
var measured: bool = false
var state = -1 # -1 default, 0 means |0> 1 means |1>
var allowed = true
var spawn_pos = Vector2.ZERO
var carried_gate

@export var hud: CanvasLayer
@onready var player: CharacterBody2D = $Player
@onready var player_2: CharacterBody2D = $Player2
@onready var midground: TileMapLayer = $Tilemap/Midground
@onready var midground_2: TileMapLayer = $Tilemap/Midground2
@onready var camera_2d: Camera2D = $Camera2D
@onready var camera0: Camera2D = $Player/Camera2D
@onready var camera1: Camera2D = $Player2/Camera2D
@onready var timer: Timer = $Timer
@onready var puzzle_1: Node = $Puzzle_1

func _ready() -> void:
	score = 0
	camera_2d.make_current()
	camera_2d.global_position = camera0.global_position
	carried_gate = ""

func add_point():
	# Update coins collected
	score += 1
	hud.get_node("CoinsLabel").text = str(score)

func schedule_respawn():
	timer.start()

func _on_timer_timeout():
	Engine.time_scale = 1
	get_tree().reload_current_scene()

func measure():
	if measured:
		return state
	allowed = false
	var prob0 = cos(theta/2.0)**2
	var r = randf()
	if r < prob0:
		set_state_zero()
	else:
		state = 1
		hud.get_node("Percent0").text = str(0.0)
		hud.get_node("Percent1").text = str(100.0)
		theta = PI
		phi = 0
		bloch_vec = Vector3(0, 0, -1)
	measured = true
	if state==0:
		theta = 0
		camera_2d.global_position = camera_2d.global_position.lerp(camera0.global_position,0.005)
	else:
		theta = PI
		camera_2d.global_position = camera_2d.global_position.lerp(camera1.global_position,0.005)
	return state

func find_safe_spawn(x_global: float, current_is_layer1: bool):
	var current_layer: TileMapLayer
	var target_layer: TileMapLayer
	if current_is_layer1:
		current_layer = midground
		target_layer = midground_2
	else:
		current_layer = midground_2
		target_layer = midground
	
	var local = target_layer.to_local(Vector2(x_global,0.0))
	var cell = target_layer.local_to_map(local)
	var cell_x = cell.x
	var used = target_layer.get_used_rect()
	
	if cell_x < used.position.x or cell_x >= used.position.x + used.size.x:
		return Vector2.INF
	
	var y_from = used.position.y - 2
	var y_to = used.position.y + used.size.y + 2
	for y in range(y_from, y_to):
		var ground = Vector2i(cell_x,y)
		var above = Vector2i(cell_x,y-1)
		
		if (target_layer.get_cell_source_id(ground) != -1) and (target_layer.get_cell_source_id(above) == -1) and (current_layer.get_cell_source_id(above) == -1):
			var tile_pos = target_layer.map_to_local(ground)
			return Vector2(x_global,target_layer.to_global(tile_pos).y)
	
	return Vector2.INF

func try_superposition(requester:CharacterBody2D)->bool:
	if not measured:
		return false
	var requester_is_layer_1 = requester==player
	var partner 
	if requester_is_layer_1:
		partner = player_2
	else:
		partner = player
	var spawn_at = find_safe_spawn(requester.global_position.x, requester_is_layer_1)
	if spawn_at == Vector2.INF:
		return false
	
	partner.global_position = spawn_at
	measured = false
	state = -1
	return true

func get_horizontal_blocked_distance(player):
	var total_blocked = 0.0
	for i in range(player.get_slide_collision_count()):
		var collision = player.get_slide_collision(i)
		var normal = collision.get_normal()
		# only consider horizontal collisions
		if abs(normal.x) > 0.7:
			# horizontal blocked, accumulate distance
			total_blocked += abs(collision.get_remainder().x)
	return total_blocked
	
func sync_players():
	# Skip collapsed players
	var active_players = []
	if player.animated_sprite_2d.self_modulate.a > 1e-5:
		active_players.append(player)
	if player_2.animated_sprite_2d.self_modulate.a > 1e-5:
		active_players.append(player_2)

	if active_players.size() < 2:
		return  # nothing to sync
	
	# Determine blocked distances using collisions
	var dist_list = []
	for p in active_players:
		dist_list.append(get_horizontal_blocked_distance(p))

	# Leader = blocked player (larger distance)
	var leader
	var follower
	if dist_list[0] >= dist_list[1]:
		leader = active_players[0]
		follower = active_players[1]
	else:
		leader = active_players[1]
		follower = active_players[0]

# Snap follower X to leader
	follower.global_position.x = leader.global_position.x

# Rotate Bloch vector about X axis by angle
func rotate_x(angle: float) -> void:
	var rot = Basis(Vector3(1, 0, 0), angle)
	bloch_vec = (rot * bloch_vec).normalized()
	_update_theta_phi()

# Rotate Bloch vector about Y axis by angle
func rotate_y(angle: float) -> void:
	var rot = Basis(Vector3(0, 1, 0), angle)
	bloch_vec = (rot * bloch_vec).normalized()
	_update_theta_phi()

# Rotate Bloch vector about Z axis by angle
func rotate_z(angle: float) -> void:
	var rot = Basis(Vector3(0, 0, 1), angle)
	bloch_vec = (rot * bloch_vec).normalized()
	_update_theta_phi()

# Convert cartesian bloch_vec → spherical angles
func _update_theta_phi() -> void:
	bloch_vec = bloch_vec.normalized()
	theta = acos(clamp(bloch_vec.z, -1.0, 1.0))  # 0 ≤ θ ≤ π
	phi = atan2(bloch_vec.y, bloch_vec.x)        # -π ≤ φ ≤ π
	if phi < 0.0:
		phi += TAU                              # 0 ≤ φ < 2π

func _is_on_interactable(p: Node):
	if not p.has_node("interact_area"):
		print("hold up")
	var area = p.get_node("interact_area")
	for body in area.get_overlapping_bodies():
		if body.is_in_group("interactables"):
			return true
	for intarea in area.get_overlapping_areas():
		if area.is_in_group("interactables"):
			return true
	return false

func _is_on_entanglable(p: Node):
	var area = p.get_node("interact_area")
	for body in area.get_overlapping_bodies():
		if body.is_in_group("entanglables"):
			return true
	for intarea in area.get_overlapping_areas():
		if area.is_in_group("entanglables"):
			return true
	return false

func _process(delta: float) -> void:
	# Update Theta
	delta_theta = delta*PI/2.0
	if !allowed:
		var requester
		if state == 0:
			requester = player
		elif state == 1:
			requester = player_2
		var ok = try_superposition(requester)
		if _is_on_interactable(player) or _is_on_interactable(player_2):
			ok = false
		if ok:
			allowed = true
	if allowed:
		if Input.is_action_pressed("x_rotation"):
			if measured:
				state = -1
			rotate_x(delta_theta)
		if Input.is_action_pressed("y_rotation"):
			if measured:
				state = -1
			rotate_y(delta_theta)
		if Input.is_action_pressed("z_rotation"):
			if measured:
				state = -1
			rotate_z(delta_theta)
	if Input.is_action_pressed("Measure"):
		if !measured:
			measure()
		
	var prob0_raw = (cos(theta/2.0)**2)*100
	var prob0 = round(prob0_raw * 10.0) / 10.0
	var prob1 = round((100 - prob0) * 10.0) / 10.0
	if prob0_raw >= 100.0-0.02:
		measured = true
		state = 0
		allowed = false
		theta = 0
		phi = 0
	elif prob0_raw <= 0.02:
		measured = true
		state = 1
		allowed = false
		theta = PI
		phi = 0

	hud.get_node("Percent0").text = str(prob0)
	hud.get_node("Percent1").text = str(prob1)
	hud.get_node("phi_value").text = str(round(rad_to_deg(phi)*10)/10)
	hud.get_node("theta_value").text = str(round(rad_to_deg(theta)*10)/10)
	hud.get_node("carried_gate").text = str(carried_gate)
	var alpha0 = player.get_node("AnimatedSprite2D").self_modulate.a
	var alpha1 = player_2.get_node("AnimatedSprite2D").self_modulate.a

	var target
	if alpha0>= alpha1:
		target = camera0
	else:
		target = camera1

	camera_2d.global_position = camera_2d.global_position.lerp(target.global_position,0.005)
	
	if Input.is_action_just_pressed("Interact"):
		if _is_on_interactable(player) or _is_on_interactable(player_2):
			if !measured:
				measure()
		var p
		if state == 0:
			p = player
		else:
			p = player_2
		var interact_area = p.get_node("interact_area")
		var bodies = interact_area.get_overlapping_bodies()
		for body in bodies:
			if body.is_in_group("interactables"):
				puzzle_1.handle_interaction(body)
		var areas = interact_area.get_overlapping_areas()
		for area in areas:
			if area.is_in_group("interactables"):
				puzzle_1.handle_interaction(area)
				
	if Input.is_action_just_pressed("c_not"):
		if _is_on_entanglable(player) or _is_on_entanglable(player_2):
			print("just did cnot")
			#var p
			#if state == 0:
				#p = player
			#else:
				#p = player_2
			#var interact_area = p.get_node("interact_area")
			#var bodies = interact_area.get_overlapping_bodies()
			#var areas = interact_area.get_overlapping_areas()
		
	
	# problem with this is if one person dies they go down and so does the camera
	#camera_2d.global_position = camera_2d.global_position.lerp((camera0.global_position+camera1.global_position)/2.0,0.005)
	
	
	 # Sync movement

func get_bloch_vector(theta_val: float, phi_val: float) -> Vector3:
	return Vector3(
		sin(theta_val) * cos(phi_val),
		sin(theta_val) * sin(phi_val),
		cos(theta_val)
	)

func compute_fidelity(target_theta: float, target_phi: float) -> float:
	var r = get_bloch_vector(theta, phi)
	var rt = get_bloch_vector(target_theta, target_phi)
	var dot = r.dot(rt)
	return 0.5 * (1.0 + dot)

func set_state_zero():
	state = 0
	hud.get_node("Percent0").text = str(100.0)
	hud.get_node("Percent1").text = str(0.0)
	theta = 0
	phi = 1
	bloch_vec = Vector3(0, 0, 1)
