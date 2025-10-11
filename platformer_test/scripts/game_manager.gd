extends Node

## PRELOAD SCRIPTS ##
const Complex = preload("res://scripts/complex.gd")
@onready var timer: Timer = $Timer
@onready var pause_ui: CanvasLayer = $Pause_UI
@onready var level_failed: CanvasLayer = $Level_failed
@onready var level_passed: CanvasLayer = $Level_passed

## GAME CONTROL ##
var current_level: Node = null
var current_level_path = ""
var next_file_path = null
var is_loading = false
var delta_theta = 0
var current_level_name

## PLAYER STATE ##
var suppos_allowed = true
var measured: bool = false
var state = -1 # -1 default, 0 means |0> 1 means |1>
var theta = 0
var phi = 0
var bloch_vec: Vector3 = Vector3(0, 0, 1)
var entangled_state = null

@export var entangled_mode = false
@export var entangled_probs = null
@export var hold_gem = null
@export var hold_enemy = null
var is_teleporting = false

## HUD VARIABLES ##
var score = 0
var coins_picked_up = []
var hearts: int = 3
var carried_gate = ""

## RESET VARIABLES ##
var hearts_reset: int = 3
var carried_gate_reset = ""
var level_start_time: float = 0.0
var level_elapsed_time: float = 0.0

## RESPAWN VARIABLES ##
var is_dead = false
var checkpoint_position_0:  Vector2
var checkpoint_position_1: Vector2
var checkpoint_player_zero

func add_point(coin_name: String) -> void:
	# Update coins collected
	score += 1
	current_level.hud.get_node("CoinsLabel").text = str(score)
	coins_picked_up.append(coin_name)
	# 5 coins = +1 heart
	if score % 5 == 0:
		hearts += 1
		current_level.hud.heart_label.text = str(hearts)
		var sound_player = get_node_or_null("Coin2Heart")
		if sound_player and not sound_player.playing:
			sound_player.play()

func schedule_respawn(dead_body: Node2D) -> void:
	# Tween fade-out
	var tween = get_tree().create_tween()
	tween.tween_property(
		dead_body, "modulate",
		Color(dead_body.modulate.r, dead_body.modulate.g, dead_body.modulate.b, 0.0),
		0.4
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	var sound_player = get_node_or_null("Killed")
	if sound_player and not sound_player.playing:
		sound_player.play()

	await sound_player.finished
	# Start respawn timer
	timer.start()

func _on_timer_timeout() -> void:
	Engine.time_scale = 1.0
	
	# Update hearts / reset game if needed
	hearts -= 1
	current_level.hud.heart_label.text = str(hearts)
	if hearts <= 0:
		score = 0
		current_level.hud.coins_label.text = str(score)
		hearts = 3
		current_level.hud.heart_label.text = str(hearts)
		coins_picked_up = []
		checkpoint_player_zero = null
		is_dead = false
		process_fail()
		return
	load_level(current_level_path)
	
	while is_loading:
		await get_tree().process_frame
	# Respawn logic
	current_level.player.global_position = checkpoint_position_0
	current_level.player_2.global_position = checkpoint_position_1
	is_dead = false
	if checkpoint_player_zero == null:
		checkpoint_player_zero = current_level.start_layer_zero
	if checkpoint_player_zero:
		theta = 0
		phi = 0
		measured = false
		measure()
		current_level.camera_2d.global_position = current_level.camera0.global_position
	else:
		theta = PI
		phi = 0
		measured = false
		measure()
		current_level.camera_2d.global_position = current_level.camera1.global_position

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
		set_state_one()
	return state

func set_state_zero():
	state = 0
	current_level.hud.get_node("Percent0").text = str(100.0)
	current_level.hud.get_node("Percent1").text = str(0.0)
	theta = 0
	phi = 0
	bloch_vec = Vector3(0, 0, 1)
	current_level.camera_2d.global_position = current_level.camera_2d.global_position.lerp(current_level.camera0.global_position,0.005)
	var sound_player = get_node_or_null("MeasureZero")
	if sound_player and not sound_player.playing:
		sound_player.play()

func set_state_one():
	state = 1
	current_level.hud.get_node("Percent0").text = str(0.0)
	current_level.hud.get_node("Percent1").text = str(100.0)
	theta = PI
	phi = 0
	bloch_vec = Vector3(0, 0, -1)
	current_level.camera_2d.global_position = current_level.camera_2d.global_position.lerp(current_level.camera1.global_position,0.005)
	var sound_player = get_node_or_null("MeasureOne")
	if sound_player and not sound_player.playing:
		sound_player.play()

func find_safe_spawn(x_global: float, current_is_layer1: bool):
	var current_layer: TileMapLayer
	var target_layer: TileMapLayer
	if current_is_layer1:
		current_layer = current_level.midground
		target_layer = current_level.midground_2
	else:
		current_layer = current_level.midground_2
		target_layer = current_level.midground
	
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
	var requester_is_layer_1 = (requester == current_level.player)
	var partner 
	if requester_is_layer_1:
		partner = current_level.player_2
	else:
		partner = current_level.player
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
	if current_level.player.animated_sprite_2d.self_modulate.a > 1e-5:
		active_players.append(current_level.player)
	if current_level.player_2.animated_sprite_2d.self_modulate.a > 1e-5:
		active_players.append(current_level.player_2)

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
	if hold_gem:
		hold_gem.instantiate_gem_process()

# Rotate Bloch vector about Y axis by angle
func rotate_y(angle: float) -> void:
	var rot = Basis(Vector3(0, 1, 0), angle)
	bloch_vec = (rot * bloch_vec).normalized()
	_update_theta_phi()
	if hold_gem:
		hold_gem.instantiate_gem_process()

# Rotate Bloch vector about Z axis by angle
func rotate_z(angle: float) -> void:
	var rot = Basis(Vector3(0, 0, 1), angle)
	bloch_vec = (rot * bloch_vec).normalized()
	_update_theta_phi()
	if hold_gem:
		hold_gem.instantiate_gem_process()

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

## ENTANGLEMENT HANDLING ##

func calculate_entangled_state(target_current_state_zero: bool) -> Array:
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

	de_entangle(outcome_idx)

	if outcome_idx == 0 or outcome_idx == 1:
		state = 0
		set_state_zero()
	else:
		state = 1
		set_state_one()
	return state

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

func edit_hud_entangle(time_taken) -> void:
	if hold_gem:
		current_level.hud.get_node("gem_carried").visible = true
	if hold_enemy:
		current_level.hud.get_node("enemy").visible = true
	current_level.hud.get_node("Bloch_Render").visible = false
	current_level.hud.get_node("X_Label").visible = false
	current_level.hud.get_node("Y_Label").visible = false
	current_level.hud.get_node("Z_Label").visible = false
	current_level.hud.get_node("1_Label").visible = false
	
	current_level.hud.get_node("0").text = "|01>: "
	current_level.hud.get_node("1").text = "|00>: "
	current_level.hud.get_node("phi").text = "|11>: "
	current_level.hud.get_node("theta").text = "|10>: "
	
	update_hud_entangle(time_taken)

func update_hud_entangle(time_taken) -> void:
	current_level.hud.get_node("Percent1").text = str(round(entangled_probs[0] * 1000.0) / 10.0)
	current_level.hud.get_node("Percent0").text = str(round(entangled_probs[1] * 1000.0) / 10.0)
	current_level.hud.get_node("phi_value").text = str(round(entangled_probs[3] * 1000.0) / 10.0)
	current_level.hud.get_node("theta_value").text = str(round(entangled_probs[2] * 1000.0) / 10.0)
	level_elapsed_time = time_taken - level_start_time
	current_level.time_taken.label_2.text = "%.1f s" % level_elapsed_time

func de_entangle(outcome_idx: int) -> void:
	entangled_mode = false
	if hold_gem:
		if outcome_idx == 1:
			hold_gem.instantiate_gem(false)
		elif outcome_idx == 2:
			hold_gem.instantiate_gem(true)
	elif hold_enemy:
		if outcome_idx == 0:
			hold_enemy.instantiate_enemy(true, true)
		elif outcome_idx == 1:
			hold_enemy.instantiate_enemy(false, false)
		elif outcome_idx == 2:
			hold_enemy.instantiate_enemy(true, false)
		else:
			hold_enemy.instantiate_enemy(false, true)
	
	edit_hud_deentangle()
	
	current_level.player.uncolor_sprite()
	current_level.player_2.uncolor_sprite()

func edit_hud_deentangle() -> void:
	if hold_gem == null:
		current_level.hud.get_node("gem_carried").visible = false
	current_level.hud.get_node("enemy").visible = false
	current_level.hud.get_node("Bloch_Render").visible = true
	current_level.hud.get_node("X_Label").visible = true
	current_level.hud.get_node("Y_Label").visible = true
	current_level.hud.get_node("Z_Label").visible = true
	current_level.hud.get_node("1_Label").visible = true
	
	current_level.hud.get_node("0").text = "|0>: "
	current_level.hud.get_node("1").text = "|1>: "
	current_level.hud.get_node("phi").text = "phi: "
	current_level.hud.get_node("theta").text = "theta: "

## INTERACTABLE / ENTANGLABLE ##

func _is_on_interactable(p: Node):
	if not p.has_node("interact_area"):
		print("hold up")
	var area = p.get_node("interact_area")
	for body in area.get_overlapping_bodies():
		if body.is_in_group("interactables_puzzle"):
			return true
		if body.is_in_group("interactables_entangle"):
			return true
	for intarea in area.get_overlapping_areas():
		if intarea.is_in_group("interactables_puzzle"):
			return true
		if intarea.is_in_group("interact_merlin"):
			return true
	return false

func _is_on_teleport(p: Node):
	if not p.has_node("interact_area"):
		print("hold up")
	if entangled_mode:
		return null
	var area = p.get_node("interact_area")
	for body in area.get_overlapping_bodies():
		if body.is_in_group("teleport_interact"):
			return body.get_parent()
	return null

func _is_on_entanglable(p: Node):
	if measured:
		if p.is_state_zero and state != 0:
			return null
		elif !p.is_state_zero and state != 1:
			return null
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

func _is_on_pressure_plate(p: Node):
	if not p.has_node("interact_area"):
		print("hold up")
	var area = p.get_node("interact_area")
	for body in area.get_overlapping_bodies():
		if body.is_in_group("pressure_plate"):
			return true
	for intarea in area.get_overlapping_areas():
		if intarea.is_in_group("pressure_plate"):
			return true
	return false

func Stopper() -> void:
	current_level.player.stop = true
	current_level.player_2.stop = true

func Starter() -> void:
	current_level.player.stop = false
	current_level.player_2.stop = false

## LEVEL HELPERS ##

func load_level(path: String):
	if current_level:
		# Stop all processing
		current_level.set_process(false)
		current_level.set_physics_process(false)
		# Queue free
		current_level.queue_free()
		current_level = null

	is_loading = true
	# Defer the new level to next frame
	call_deferred("_instantiate_level", path)

func _instantiate_level(path: String):
	var level_scene = load(path).instantiate()
	add_child(level_scene)
	current_level = level_scene
	current_level_path = path

	if next_file_path:
		level_scene.call_deferred("set_game_manager", self, next_file_path)
	elif level_scene.has_method("set_game_manager"):
		level_scene.call_deferred("set_game_manager", self)
	is_loading = false

func process_superposition():
	if !suppos_allowed:
		var requester
		if state == 0:
			requester = current_level.player
		elif state == 1:
			requester = current_level.player_2
		var ok = try_superposition(requester)
		if _is_on_interactable(current_level.player) or _is_on_interactable(current_level.player_2):
			ok = false
		if _is_on_teleport(current_level.player) or _is_on_teleport(current_level.player_2):
			ok = false
		if _is_on_pressure_plate(current_level.player) or _is_on_pressure_plate(current_level.player_2):
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

func process_update_hud(time_taken):
	var prob0_raw = (cos(theta/2.0)**2)*100
	var prob0 = round(prob0_raw * 10.0) / 10.0
	var prob1 = round((100 - prob0) * 10.0) / 10.0
	level_elapsed_time = time_taken - level_start_time
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
	current_level.hud.get_node("Percent0").text = str(prob0)
	current_level.hud.get_node("Percent1").text = str(prob1)
	current_level.hud.get_node("phi_value").text = str(round(rad_to_deg(phi)*10)/10)
	current_level.hud.get_node("theta_value").text = str(round(rad_to_deg(theta)*10)/10)
	current_level.time_taken.label_2.text = "%.1f s" % level_elapsed_time

func process_camera():
	var alpha0 = current_level.player.get_node("AnimatedSprite2D").self_modulate.a
	var alpha1 = current_level.player_2.get_node("AnimatedSprite2D").self_modulate.a
	var camera_target
	if alpha0 >= alpha1:
		camera_target = current_level.camera0
	else:
		camera_target = current_level.camera1
	current_level.camera_2d.global_position = current_level.camera_2d.global_position.lerp(camera_target.global_position, 0.005)

func process_interact():
	if Input.is_action_just_pressed("Interact"):
		var teleport_player = _is_on_teleport(current_level.player)
		var teleport_player2 = _is_on_teleport(current_level.player_2)
		if _is_on_interactable(current_level.player) or _is_on_interactable(current_level.player_2):
			if !measured:
				measure()
		elif teleport_player:
			teleport_player.run_teleportation()
		elif teleport_player2:
			teleport_player2.run_teleportation()
		
		var p
		if state == 0:
			p = current_level.player
		else:
			p = current_level.player_2
		var interact_area = p.get_node("interact_area")
		var bodies = interact_area.get_overlapping_bodies()
		for body in bodies:
			if body.is_in_group("interactables_puzzle"):
				var current_puzzle = body.get_parent().get_parent()
				current_puzzle.handle_interaction(body)
			if body.is_in_group("interactables_entangle"):
				var current_entangle_block = body.get_parent()
				current_entangle_block._gem_block(body)
				
		var areas = interact_area.get_overlapping_areas()
		for area in areas:
			if area.is_in_group("interactables_puzzle"):
				var current_puzzle = area.get_parent().get_parent()
				current_puzzle.handle_interaction(area)
			if area.is_in_group("interact_merlin"):
				var current_merlin = area.get_parent()
				current_merlin.handle_interaction()

func process_entanglement(time_taken):
	if entangled_mode:
		return
	
	if Input.is_action_just_pressed("c_not"):
		var target = _is_on_entanglable(current_level.player)
		if target == null:
			target = _is_on_entanglable(current_level.player_2)
			
		if target != null:
			var target_parent = target.get_parent()
			target_parent.handle_entanglement(target)
			entangled_mode = true
			entangled_state = calculate_entangled_state(target.is_state_zero)
			entangled_probs = calculate_entangled_probs()
			edit_hud_entangle(time_taken)
			current_level.player.color_sprite()
			current_level.player_2.color_sprite()
			target.queue_free()
			
			var sound_player = get_node_or_null("Entangle")
			if sound_player and not sound_player.playing:
				sound_player.play()

func process_pause():
	if Input.is_action_just_pressed("pause"):
		if !get_tree().paused:
			pause_ui.panel._update_from_audio_bus()
			get_tree().paused = true
			pause_ui.visible = true

func process_fail():
	if !get_tree().paused:
		get_tree().paused = true
		level_failed.visible = true

func process_success():
	randomize()
	level_passed.label.text = level_passed.SUCCESS_MESSAGES[randi() % level_passed.SUCCESS_MESSAGES.size()]
	var final_score = (score*10 + hearts*50) *clamp(300.0/level_elapsed_time,0.5,5) 
	var parsedResult
	var path = "res://scripts/player_data.json"
	if FileAccess.file_exists(path):
		var f = FileAccess.open(path, FileAccess.READ)
		parsedResult = JSON.parse_string(f.get_as_text())
	else:
		parsedResult = {}
	var index = 0
	for level_dict in parsedResult["highscore"]:
		if level_dict.has(current_level_name):
			break
		index+=1
	if parsedResult["highscore"][index][current_level_name]< final_score:
		parsedResult["highscore"][index][current_level_name] = final_score
		level_passed.label_3.visible = true
	var save_file = FileAccess.open(path, FileAccess.WRITE)
	if save_file:
		save_file.store_string(JSON.stringify(parsedResult," "))
		save_file.close()
	level_passed.label_2.text = "Coins: " + str(score) + "\n\nHearts: " + str(hearts) + "\n\nTime: " + "%.2f s" % level_elapsed_time + "\n\nFinal Score: " + "%.2f" %final_score
	score = 0
	current_level.hud.coins_label.text = str(score)
	hearts = 3
	current_level.hud.heart_label.text = str(hearts)
	coins_picked_up = []
	checkpoint_player_zero = null
	is_dead = false
	get_tree().paused = true
	level_passed.visible = true

## PROCESS ##

func _process(_delta: float) -> void:
	if current_level == null:
		pause_ui.visible = false
		level_failed.visible = false
		level_passed.visible = false
		load_level("res://scenes/start_screen.tscn")

func progress_reset() -> void:
	hearts = hearts_reset
	coins_picked_up = []
	carried_gate = carried_gate_reset
	score = 0
	level_start_time = 0.0
	level_elapsed_time = 0.0
	checkpoint_player_zero = null
	is_dead = false
