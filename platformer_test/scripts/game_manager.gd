extends Node

const Complex = preload("res://complex.gd")

var score = 0
var theta = 0
var phi = 0
var delta_theta = 0
var bloch_vec: Vector3 = Vector3(0, 0, 1)
var measured: bool = false
var measured_only_player: bool = false
var state = -1 # -1 default, 0 means |0> 1 means |1>
var suppos_allowed = true
var carried_gate
var entangled_state = null

@export var entangled_mode = false
@export var hud: CanvasLayer
@export var entangled_probs = null
@onready var player: CharacterBody2D = $Player
@onready var player_2: CharacterBody2D = $Player2
@onready var midground: TileMapLayer = $Tilemap/Midground
@onready var midground_2: TileMapLayer = $Tilemap/Midground2
@onready var camera_2d: Camera2D = $Camera2D
@onready var camera0: Camera2D = $Player/Camera2D
@onready var camera1: Camera2D = $Player2/Camera2D
@onready var timer: Timer = $Timer
@onready var puzzle_1: Node = $"../Puzzle_1"
@onready var gem: Node = $Gem

func _ready() -> void:
	score = 0
	camera_2d.make_current()
	camera_2d.global_position = camera0.global_position
	carried_gate = ""
	var entanglables = [
		gem
	]
	for block in entanglables:
		if block != null:
			block.add_to_group("entanglables")

func add_point():
	# Update coins collected
	score += 1
	hud.get_node("CoinsLabel").text = str(score)

func schedule_respawn():
	timer.start()

func _on_timer_timeout():
	Engine.time_scale = 1
	get_tree().reload_current_scene()

## SUPERPOSITION HANDLING ##

func measure():
	if measured:
		return state
	measured = true
	suppos_allowed = false
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
		camera_2d.global_position = camera_2d.global_position.lerp(camera1.global_position,0.005)
	return state

func set_state_zero():
	state = 0
	hud.get_node("Percent0").text = str(100.0)
	hud.get_node("Percent1").text = str(0.0)
	theta = 0
	phi = 1
	bloch_vec = Vector3(0, 0, 1)
	camera_2d.global_position = camera_2d.global_position.lerp(camera0.global_position,0.005)

func find_safe_spawn(x_global: float, current_is_layer1: bool):
	var current_layer: TileMapLayer
	var target_layer: TileMapLayer
	if current_is_layer1:
		current_layer = midground
		target_layer = midground_2
	else:
		current_layer = midground_2
		target_layer = midground
	
	var local_coord = target_layer.to_local(Vector2(x_global,0.0))
	var cell = target_layer.local_to_map(local_coord)
	var cell_x = cell.x
	var target_location = target_layer.get_used_rect()
	
	if cell_x < target_location.position.x or cell_x >= target_location.position.x + target_location.size.x:
		return Vector2.INF
	
	var y_from = target_location.position.y - 2
	var y_to = target_location.position.y + target_location.size.y + 2
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
	var requester_is_layer_1 = (requester == player)
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
	measured_only_player = false
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

## BLOCH SPHERE ##

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

## INTERACTABLE / ENTANGLABLE ##

func _is_on_interactable(p: Node):
	if not p.has_node("interact_area"):
		print("hold up")
	var area = p.get_node("interact_area")
	for body in area.get_overlapping_bodies():
		if body.is_in_group("interactables"):
			return true
	for intarea in area.get_overlapping_areas():
		if intarea.is_in_group("interactables"):
			return true
	return false

func _is_on_entanglable(p: Node):
	if not p.has_node("interact_area"):
		print("hold up") # shouldn't happen
	var area = p.get_node("interact_area")
	for body in area.get_overlapping_bodies():
		if body.is_in_group("entanglables"):
			return body
	for intarea in area.get_overlapping_areas():
		if intarea.is_in_group("entanglables"):
			return intarea
	return null

## ENTANGLEMENT HANDLING ##

func calculate_entangled_state(phi: float, theta: float, target_current_state_zero: bool) -> Array:
	var cos_val = Complex.new(cos(theta / 2.0), 0)
	var sin_val = Complex.new(sin(theta / 2.0), 0)
	var state: Array
	var phase = Complex.new(cos(phi), sin(phi))  # e^{i phi}
	
	if target_current_state_zero:
		# [cos, 0, 0, e^{i phi} * sin]
		state = [
			cos_val,
			Complex.new(0, 0),
			Complex.new(0, 0),
			phase.mul(sin_val)
		]
	else:
		# [0, cos, e^{i phi} * sin, 0]
		state = [
			Complex.new(0, 0),
			cos_val,
			phase.mul(sin_val),
			Complex.new(0, 0)
		]
	return state

func calculate_entangled_probs():
	var probs = []
	for amp in entangled_state:
		probs.append(amp.abs()**2)
	return probs

func measure_entangled() -> int:
	if measured:
		return state
	
	measured = true
	suppos_allowed = false

	# Sample outcome from full joint distribution
	var r = randf()
	var cumulative = 0.0
	var outcome_idx = 0
	for i in range(entangled_probs.size()):
		cumulative += entangled_probs[i]
		if r < cumulative:
			outcome_idx = i
			break

	# Collapse: keep only chosen basis state
	var collapsed: Array = []
	for i in range(4):
		if i == outcome_idx:
			collapsed.append(Complex.new(1, 0))  # pure basis state
		else:
			collapsed.append(Complex.new(0, 0))

	# Replace global state
	entangled_state = collapsed
	entangled_probs = calculate_entangled_probs()

	if outcome_idx == 0 or outcome_idx == 1:
		state = 0
	else:
		state = 1

	return state

func measure_entangled_only_player() -> int:
	if measured:
		return state
	if measured_only_player:
		return state
	measured_only_player = true
	suppos_allowed = false
	
	# Compute marginal probs for measuring player qubit in Z
	var prob_zero = entangled_probs[0] + entangled_probs[1]
	var prob_one  = entangled_probs[2] + entangled_probs[3]

	# Sample outcome
	var r = randf()
	var outcome_player: int
	if r < prob_zero:
		outcome_player = 0
	else:
		outcome_player = 1

	# Collapse state
	var collapsed: Array = []
	if outcome_player == 0:
		collapsed = [entangled_state[0], entangled_state[1], Complex.new(0,0), Complex.new(0,0)]
	else:
		collapsed = [Complex.new(0,0), Complex.new(0,0), entangled_state[2], entangled_state[3]]

	# Renormalize
	var norm = 0.0
	for amp in collapsed:
		norm += amp.abs()**2
	if norm > 0:
		for i in range(collapsed.size()):
			collapsed[i] = collapsed[i].div(Complex.new(sqrt(norm), 0))

	# Replace global state
	entangled_state = collapsed
	entangled_probs = calculate_entangled_probs()
	state = outcome_player
	return outcome_player

func rotate_x_entangled(angle: float) -> void:
	var c = cos(angle/2.0)
	var s = -sin(angle/2.0) # minus for exp(-i θ σ/2)
	var x_gate = [
		[Complex.new(c, 0), Complex.new(0, s)],
		[Complex.new(0, s), Complex.new(c, 0)]
	]
	apply_gate_entangled(x_gate)

func rotate_y_entangled(angle: float) -> void:
	var c = cos(angle/2.0)
	var s = sin(angle/2.0)
	var y_gate = [
		[Complex.new(c, 0), Complex.new(-s, 0)],
		[Complex.new(s, 0), Complex.new(c, 0)]
	]
	apply_gate_entangled(y_gate)

func rotate_z_entangled(angle: float) -> void:
	var e_minus = Complex.new(cos(-angle/2.0), sin(-angle/2.0))
	var e_plus  = Complex.new(cos(angle/2.0),  sin(angle/2.0))
	var z_gate = [
		[ e_minus, Complex.new(0,0)],
		[ Complex.new(0,0), e_plus ]
	]
	apply_gate_entangled(z_gate)

func apply_gate_entangled(U: Array) -> void:
	var gate = [
		[U[0][0], Complex.new(0,0), U[0][1], Complex.new(0,0)],
		[Complex.new(0,0), U[0][0], Complex.new(0,0), U[0][1]],
		[U[1][0], Complex.new(0,0), U[1][1], Complex.new(0,0)],
		[Complex.new(0,0), U[1][0], Complex.new(0,0), U[1][1]]
	]
	
	var new_state = []
	for i in range(4):
		var acc = Complex.new(0,0)
		for j in range(4):
			acc = acc.add(gate[i][j].mul(entangled_state[j]))
		new_state.append(acc)
	
	entangled_state = new_state
	entangled_probs = calculate_entangled_probs()

func edit_hud_items() -> void:
	hud.get_node("BlochSphere").visible = false
	hud.get_node("0_Bloch").visible = false
	hud.get_node("1_Bloch").visible = false
	
	hud.get_node("0").text = "|01>: "
	hud.get_node("1").text = "|00>: "
	hud.get_node("phi").text = "|11>: "
	hud.get_node("theta").text = "|10>: "
	
	update_hud_probabilities()

func update_hud_probabilities() -> void:
	hud.get_node("Percent1").text = str(round(entangled_probs[0] * 1000.0) / 10.0)
	hud.get_node("Percent0").text = str(round(entangled_probs[1] * 1000.0) / 10.0)
	hud.get_node("phi_value").text = str(round(entangled_probs[3] * 1000.0) / 10.0)
	hud.get_node("theta_value").text = str(round(entangled_probs[2] * 1000.0) / 10.0)

## PROCESS ##

func _process(delta: float) -> void:
	delta_theta = delta*PI/2.0
	if !suppos_allowed:
		var requester
		if state == 0:
			requester = player
		elif state == 1:
			requester = player_2
		var ok = try_superposition(requester)
		if _is_on_interactable(player) or _is_on_interactable(player_2):
			ok = false
		if ok:
			suppos_allowed = true
	if suppos_allowed:
		if Input.is_action_pressed("x_rotation"):
			if measured:
				state = -1
			if !entangled_mode:
				rotate_x(delta_theta)
			else:
				rotate_x_entangled(delta_theta)
		if Input.is_action_pressed("y_rotation"):
			if measured:
				state = -1
			if !entangled_mode:
				rotate_y(delta_theta)
			else:
				rotate_y_entangled(delta_theta)
		if Input.is_action_pressed("z_rotation"):
			if measured:
				state = -1
			if !entangled_mode:
				rotate_z(delta_theta)
			else:
				rotate_z_entangled(delta_theta)
	if Input.is_action_pressed("Measure"):
		if !measured and !entangled_mode:
			measure()
		elif !measured and entangled_mode:
			measure_entangled()
	if Input.is_action_just_pressed("EntMeasureOnlyPlayer"):
		if entangled_mode and !measured and !measured_only_player:
			measure_entangled_only_player()

	if !entangled_mode:
		var prob0_raw = (cos(theta/2.0)**2)*100
		var prob0 = round(prob0_raw * 10.0) / 10.0
		var prob1 = round((100 - prob0) * 10.0) / 10.0
		if prob0_raw >= 100.0-0.02:
			measured = true
			state = 0
			suppos_allowed = false
			theta = 0
			phi = 0
		elif prob0_raw <= 0.02:
			measured = true
			state = 1
			suppos_allowed = false
			theta = PI
			phi = 0
		hud.get_node("Percent0").text = str(prob0)
		hud.get_node("Percent1").text = str(prob1)
		hud.get_node("phi_value").text = str(round(rad_to_deg(phi)*10)/10)
		hud.get_node("theta_value").text = str(round(rad_to_deg(theta)*10)/10)
	else:
		update_hud_probabilities()
		
	hud.get_node("carried_gate").text = str(carried_gate)
	
	var alpha0 = player.get_node("AnimatedSprite2D").self_modulate.a
	var alpha1 = player_2.get_node("AnimatedSprite2D").self_modulate.a
	var camera_target
	if alpha0 >= alpha1:
		camera_target = camera0
	else:
		camera_target = camera1

	camera_2d.global_position = camera_2d.global_position.lerp(camera_target.global_position,0.005)
	
	if Input.is_action_just_pressed("Interact"):
		if _is_on_interactable(player) or _is_on_interactable(player_2):
			if entangled_mode: ## TODO: Improve handling for this case
				set_state_zero()
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
		var target = _is_on_entanglable(player)
		if target == null:
			target = _is_on_entanglable(player_2)
		
		if target != null:
			entangled_mode = true
			# player is always the control, object is always the target
			entangled_state = calculate_entangled_state(phi, theta, target.is_state_zero)
			entangled_probs = calculate_entangled_probs()
			edit_hud_items()
			
			player.color_sprite()
			player_2.color_sprite()
			target.queue_free()
