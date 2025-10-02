extends Node

## GAME MANAGER INSTANCE ##
var game_manager: Node = null

## LEVEL-0 OBJECT INSTANCES ##
@onready var player: CharacterBody2D = $Player
@onready var player_2: CharacterBody2D = $Player2

## LEVEL-0 VARIABLES ##
var checkpoint_position_0:  Vector2
var checkpoint_position_1: Vector2
var checkpoint_player

func _ready() -> void:
	checkpoint_player = player
	checkpoint_position_0 = player.global_position
	checkpoint_position_1 = player_2.global_position

func set_game_manager(manager: Node):
	game_manager = manager

func _process(delta: float) -> void:
	# This ensures process doesn't run before level is loaded
	if game_manager == null:
		return
	
	game_manager.delta_theta = delta*PI/2.0
	if !game_manager.suppos_allowed:
		var requester
		if game_manager.state == 0:
			requester = game_manager.player
		elif game_manager.state == 1:
			requester = game_manager.player_2
		#var ok = try_superposition(requester)
		#if _is_on_interactable(player) or _is_on_interactable(player_2):
			#ok = false
		#if ok:
			#suppos_allowed = true
	#if suppos_allowed:
		#if Input.is_action_pressed("x_rotation"):
			#if measured:
				#state = -1
			#if !entangled_mode:
				#rotate_x(delta_theta)
			#else:
				#rotate_x_entangled(delta_theta)
		#if Input.is_action_pressed("y_rotation"):
			#if measured:
				#state = -1
			#if !entangled_mode:
				#rotate_y(delta_theta)
			#else:
				#rotate_y_entangled(delta_theta)
		#if Input.is_action_pressed("z_rotation"):
			#if measured:
				#state = -1
			#if !entangled_mode:
				#rotate_z(delta_theta)
			#else:
				#rotate_z_entangled(delta_theta)
	#if Input.is_action_pressed("Measure"):
		#if !measured and !entangled_mode:
			#measure()
		#elif !measured and entangled_mode:
			#measure_entangled()
	#if Input.is_action_just_pressed("EntMeasureOnlyPlayer"):
		#if entangled_mode and !measured and !measured_only_player:
			#measure_entangled_only_player()
#
	#if !entangled_mode:
		#var prob0_raw = (cos(theta/2.0)**2)*100
		#var prob0 = round(prob0_raw * 10.0) / 10.0
		#var prob1 = round((100 - prob0) * 10.0) / 10.0
		#if prob0_raw >= 100.0-0.02:
			#measured = true
			#state = 0
			#suppos_allowed = false
			#theta = 0
			#phi = 0
		#elif prob0_raw <= 0.02:
			#measured = true
			#state = 1
			#suppos_allowed = false
			#theta = PI
			#phi = 0
		#hud.get_node("Percent0").text = str(prob0)
		#hud.get_node("Percent1").text = str(prob1)
		#hud.get_node("phi_value").text = str(round(rad_to_deg(phi)*10)/10)
		#hud.get_node("theta_value").text = str(round(rad_to_deg(theta)*10)/10)
	#else:
		#update_hud_entangle()
	#
	#hud.get_node("carried_gate").text = str(carried_gate)
	#
	#var alpha0 = player.get_node("AnimatedSprite2D").self_modulate.a
	#var alpha1 = player_2.get_node("AnimatedSprite2D").self_modulate.a
	#var camera_target
	#if alpha0 >= alpha1:
		#camera_target = camera0
	#else:
		#camera_target = camera1
#
	#camera_2d.global_position = camera_2d.global_position.lerp(camera_target.global_position,0.005)
	#
	#if Input.is_action_just_pressed("Interact"):
		#if _is_on_interactable(player) or _is_on_interactable(player_2):
			#if !measured:
				#measure()
		#elif _is_on_teleport(player) or _is_on_teleport(player_2):
			#teleportation.run_teleportation()
		#var p
		#if state == 0:
			#p = player
		#else:
			#p = player_2
		#var interact_area = p.get_node("interact_area")
		#var bodies = interact_area.get_overlapping_bodies()
		#for body in bodies:
			#if body.is_in_group("interactables"):
				#puzzle_1.handle_interaction(body)
		#var areas = interact_area.get_overlapping_areas()
		#for area in areas:
			#if area.is_in_group("interactables"):
				#puzzle_1.handle_interaction(area)
	#
	#if Input.is_action_just_pressed("c_not"):
		#var target = _is_on_entanglable(player)
		#if target == null:
			#target = _is_on_entanglable(player_2)
		#
		#if target != null:
			#if target.name == "Gem":
				#hold_gem = true
			#elif target.name == "EntangleEnemy":
				#hold_enemy = true
				#ent_enemy_position = target.global_position.x
			#elif target.name == "EntangleEnemy2":
				#hold_enemy = true
				#ent_enemy_position = pressure_plate.global_position.x
				#ent_enemy_y_displacement = -20
#
			#entangled_mode = true
			## player is the control, object is the target
			#entangled_state = calculate_entangled_state(phi, theta, target.is_state_zero)
			#entangled_probs = calculate_entangled_probs()
			#edit_hud_entangle()
			#
			#player.color_sprite()
			#player_2.color_sprite()
			#target.queue_free()
