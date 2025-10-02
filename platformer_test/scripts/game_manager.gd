extends Node

## PRELOAD SCRIPTS ##
const Complex = preload("res://scripts/complex.gd")

## GAME CONTROL ##
var current_level: Node = null
var delta_theta = 0

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
@export var hold_gem = false
@export var hold_enemy = false

## HUD VARIABLES ##
var score = 0
var hearts: int = 3
var carried_gate = ""

## RESPAWN VARIABLES ##
var pending_respawn
var is_dead = false
var checkpoint_position_0:  Vector2
var checkpoint_position_1: Vector2
var checkpoint_player

func add_point():
	# Update coins collected
	score += 1
	current_level.hud.get_node("CoinsLabel").text = str(score)
	# 5 coins = +1 heart
	if score % 5 == 0:
		hearts += 1
		current_level.hud.heart_label.text = str(hearts)

func schedule_respawn(dead_body: Node2D) -> void:
	pending_respawn = dead_body
	# Tween fade-out
	var tween = get_tree().create_tween()
	tween.tween_property(
		pending_respawn, "modulate",
		Color(pending_respawn.modulate.r, pending_respawn.modulate.g, pending_respawn.modulate.b, 0.0),
		0.4
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	# Start respawn timer
	current_level.timer.start()

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
		get_tree().reload_current_scene()
		return

	# Respawn logic
	var respawn_player: Node2D = pending_respawn
	pending_respawn.get_node("CollisionShape2D").disabled = false
	current_level.player.global_position = checkpoint_position_0
	current_level.player_2.global_position = checkpoint_position_1
	is_dead = false
	if checkpoint_player == current_level.player:
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

	# Make player invisible first
	respawn_player.modulate.a = 0.0

	# Tween fade-in
	var tween = get_tree().create_tween()
	tween.tween_property(
		respawn_player, "modulate",
		Color(respawn_player.modulate.r, respawn_player.modulate.g, respawn_player.modulate.b, 1.0),
		0.4
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)

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

func set_state_one():
	state = 1
	current_level.hud.get_node("Percent0").text = str(0.0)
	current_level.hud.get_node("Percent1").text = str(100.0)
	theta = PI
	phi = 0
	bloch_vec = Vector3(0, 0, -1)
	current_level.camera_2d.global_position = current_level.camera_2d.global_position.lerp(current_level.camera1.global_position,0.005)

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
	#instantiate_gem_process(): TODO: Add this back correctly

# Rotate Bloch vector about Y axis by angle
func rotate_y(angle: float) -> void:
	var rot = Basis(Vector3(0, 1, 0), angle)
	bloch_vec = (rot * bloch_vec).normalized()
	_update_theta_phi()
	#instantiate_gem_process()

# Rotate Bloch vector about Z axis by angle
func rotate_z(angle: float) -> void:
	var rot = Basis(Vector3(0, 0, 1), angle)
	bloch_vec = (rot * bloch_vec).normalized()
	_update_theta_phi()
	#instantiate_gem_process()

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

func update_hud():
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
	current_level.hud.get_node("Percent0").text = str(prob0)
	current_level.hud.get_node("Percent1").text = str(prob1)
	current_level.hud.get_node("phi_value").text = str(round(rad_to_deg(phi)*10)/10)
	current_level.hud.get_node("theta_value").text = str(round(rad_to_deg(theta)*10)/10)

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

func _is_on_teleport(p: Node):
	if not p.has_node("interact_area"):
		print("hold up")
	var area = p.get_node("interact_area")
	for body in area.get_overlapping_bodies():
		if body.is_in_group("teleport_interact"):
			return true
	
	return false

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

func Stopper() -> void:
	current_level.player.stop = true
	current_level.player_2.stop = true

func Starter() -> void:
	current_level.player.stop = false
	current_level.player_2.stop = false

## LEVEL LOAD LOGIC ##

func load_level(path: String):
	## TODO: Better handling needed than queue_free()
	if current_level:
		current_level.queue_free()
	
	var level_scene = load(path).instantiate()
	add_child(level_scene)
	current_level = level_scene
	if level_scene.has_method("set_game_manager"):
		level_scene.set_game_manager(self)

## PROCESS ##

func _process(_delta: float) -> void:
	## TODO: Add start / end scenes etc.
	if current_level == null:
		load_level("res://scenes/level0.tscn")
