extends Node
#
#var gem_scene: PackedScene = preload("res://scenes/objects/gem.tscn")
#var ent_enemy_scene: PackedScene = preload("res://scenes/objects/entangle_enemy.tscn")
#
#@onready var teleportation: Node2D = $Teleportation
#@onready var gem: Node = $EntangledGem/Gem
#@onready var ent_enemy: Node = $EntangleEnemy
#@onready var ent_enemy_pressure: Node = $EntangleEnemy2
#@onready var pressure_lock: Node = $PressureKeyLock/PressureLock
#@onready var pressure_plate: Node = $PressureKeyLock/PressurePlate
#



#func _ready() -> void:
	#var entanglables = [
		#gem,
		#ent_enemy,
		#ent_enemy_pressure
	#]
	#for block in entanglables:
		#if block != null:
			#block.add_to_group("entanglables")
	#pressure_plate.get_node("Area2D").pressed.connect(pressure_lock.open)
	#pressure_plate.get_node("Area2D").released.connect(pressure_lock.close)
#
#func instantiate_gem(level_zero: bool) -> void:
	#game_manager.hold_gem = false
	#var gem = gem_scene.instantiate()
	#if level_zero:
		#gem.is_state_zero = true
		#gem.global_position = current_level.player.global_position + Vector2(0, -10)
	#else:
		#gem.is_state_zero = false
		#gem.global_position = current_level.player_2.global_position + Vector2(0, -10)
	#get_tree().current_scene.add_child(gem)
	#gem.add_to_group("entanglables")
	#
	#current_level.hud.get_node("gem_carried").visible = false
	#

## ENTANGLEMENT HANDLING ##

#func calculate_entangled_state(phi: float, theta: float, target_current_state_zero: bool) -> Array:
	#var cos_val = Complex.new(cos(theta / 2.0), 0)
	#var sin_val = Complex.new(sin(theta / 2.0), 0)
	#var state: Array
	#var phase = Complex.new(cos(phi), sin(phi))  # e^{i phi}
	#
	#if target_current_state_zero:
		## [cos, 0, 0, e^{i phi} * sin]
		#state = [
			#cos_val,
			#Complex.new(0, 0),
			#Complex.new(0, 0),
			#phase.mul(sin_val)
		#]
	#else:
		## [0, cos, e^{i phi} * sin, 0]
		#state = [
			#Complex.new(0, 0),
			#cos_val,
			#phase.mul(sin_val),
			#Complex.new(0, 0)
		#]
	#return state
#
#func calculate_entangled_probs():
	#var probs = []
	#for amp in entangled_state:
		#probs.append(amp.abs()**2)
	#return probs
#
#func measure_entangled() -> int:
	#if measured:
		#return state
	#
	#measured = true
	#suppos_allowed = false
#
	## Sample outcome from full joint distribution
	#var r = randf()
	#var cumulative = 0.0
	#var outcome_idx = 0
	#for i in range(entangled_probs.size()):
		#cumulative += entangled_probs[i]
		#if r < cumulative:
			#outcome_idx = i
			#break
	#
	## ========================= #
	## no need to update anymore because we collapse 2 qubit state
	## but this exists in case we want to add it back
	## var collapsed: Array = []
	## for i in range(4):
		## if i == outcome_idx:
			## collapsed.append(Complex.new(1, 0))  # pure basis state
		## else:
			## collapsed.append(Complex.new(0, 0))
	## entangled_state = collapsed
	## entangled_probs = calculate_entangled_probs()
	## ========================= #
#
	#de_entangle(outcome_idx)
#
	#if outcome_idx == 0 or outcome_idx == 1:
		#state = 0
		#set_state_zero()
	#else:
		#state = 1
		#set_state_one()
#
	#return state

## LEGACY FUNCTION ##
#func measure_entangled_only_player() -> int:
	#if measured:
		#return state
	#suppos_allowed = false
	#
	## Compute marginal probs for measuring player qubit in Z
	#var prob_zero = entangled_probs[0] + entangled_probs[1]
	#var prob_one  = entangled_probs[2] + entangled_probs[3]
#
	## Sample outcome
	#var r = randf()
	#var outcome_player: int
	#if r < prob_zero:
		#outcome_player = 0
	#else:
		#outcome_player = 1
#
	## Collapse state
	#var collapsed: Array = []
	#if outcome_player == 0:
		#collapsed = [entangled_state[0], entangled_state[1], Complex.new(0,0), Complex.new(0,0)]
	#else:
		#collapsed = [Complex.new(0,0), Complex.new(0,0), entangled_state[2], entangled_state[3]]
#
	## Renormalize
	#var norm = 0.0
	#for amp in collapsed:
		#norm += amp.abs()**2
	#if norm > 0:
		#for i in range(collapsed.size()):
			#collapsed[i] = collapsed[i].div(Complex.new(sqrt(norm), 0))
#
	## Replace global state
	#entangled_state = collapsed
	#entangled_probs = calculate_entangled_probs()
	#state = outcome_player
	#return outcome_player
#
#func rotate_x_entangled(angle: float) -> void:
	#var c = cos(angle/2.0)
	#var s = -sin(angle/2.0) # minus for exp(-i θ σ/2)
	#var x_gate = [
		#[Complex.new(c, 0), Complex.new(0, s)],
		#[Complex.new(0, s), Complex.new(c, 0)]
	#]
	#apply_gate_entangled(x_gate)
#
#func rotate_y_entangled(angle: float) -> void:
	#var c = cos(angle/2.0)
	#var s = sin(angle/2.0)
	#var y_gate = [
		#[Complex.new(c, 0), Complex.new(-s, 0)],
		#[Complex.new(s, 0), Complex.new(c, 0)]
	#]
	#apply_gate_entangled(y_gate)
#
#func rotate_z_entangled(angle: float) -> void:
	#var e_minus = Complex.new(cos(-angle/2.0), sin(-angle/2.0))
	#var e_plus  = Complex.new(cos(angle/2.0),  sin(angle/2.0))
	#var z_gate = [
		#[ e_minus, Complex.new(0,0)],
		#[ Complex.new(0,0), e_plus ]
	#]
	#apply_gate_entangled(z_gate)
#
#func apply_gate_entangled(U: Array) -> void:
	#var gate = [
		#[U[0][0], Complex.new(0,0), U[0][1], Complex.new(0,0)],
		#[Complex.new(0,0), U[0][0], Complex.new(0,0), U[0][1]],
		#[U[1][0], Complex.new(0,0), U[1][1], Complex.new(0,0)],
		#[Complex.new(0,0), U[1][0], Complex.new(0,0), U[1][1]]
	#]
	#
	#var new_state = []
	#for i in range(4):
		#var acc = Complex.new(0,0)
		#for j in range(4):
			#acc = acc.add(gate[i][j].mul(entangled_state[j]))
		#new_state.append(acc)
	#
	#entangled_state = new_state
	#entangled_probs = calculate_entangled_probs()
#
#func edit_hud_entangle() -> void:
	#if hold_gem:
		#current_level.hud.get_node("gem_carried").visible = true
	#if hold_enemy:
		#current_level.hud.get_node("enemy").visible = true
	#current_level.hud.get_node("BlochSphere").visible = false
	#current_level.hud.get_node("0_Bloch").visible = false
	#current_level.hud.get_node("1_Bloch").visible = false
	#
	#current_level.hud.get_node("0").text = "|01>: "
	#current_level.hud.get_node("1").text = "|00>: "
	#current_level.hud.get_node("phi").text = "|11>: "
	#current_level.hud.get_node("theta").text = "|10>: "
	#
	#update_hud_entangle()
#
#func update_hud_entangle() -> void:
	#current_level.hud.get_node("Percent1").text = str(round(entangled_probs[0] * 1000.0) / 10.0)
	#current_level.hud.get_node("Percent0").text = str(round(entangled_probs[1] * 1000.0) / 10.0)
	#current_level.hud.get_node("phi_value").text = str(round(entangled_probs[3] * 1000.0) / 10.0)
	#current_level.hud.get_node("theta_value").text = str(round(entangled_probs[2] * 1000.0) / 10.0)
#
#func de_entangle(outcome_idx: int) -> void:
	#entangled_mode = false
	#if hold_gem:
		#if outcome_idx == 1:
			#instantiate_gem(false)
		#elif outcome_idx == 2:
			#instantiate_gem(true)
	#elif hold_enemy:
		#if outcome_idx == 0:
			#instantiate_enemy(true, true)
		#elif outcome_idx == 1:
			#instantiate_enemy(false, false)
		#elif outcome_idx == 2:
			#instantiate_enemy(true, false)
		#else:
			#instantiate_enemy(false, true)
	#
	#edit_hud_deentangle()
	#
	#current_level.player.uncolor_sprite()
	#current_level.player_2.uncolor_sprite()
#
#func edit_hud_deentangle() -> void:
	#if !hold_gem:
		#current_level.hud.get_node("gem_carried").visible = false
	#current_level.hud.get_node("enemy").visible = false
	#current_level.hud.get_node("BlochSphere").visible = true
	#current_level.hud.get_node("0_Bloch").visible = true
	#current_level.hud.get_node("1_Bloch").visible = true
	#
	#current_level.hud.get_node("0").text = "|0>: "
	#current_level.hud.get_node("1").text = "|1>: "
	#current_level.hud.get_node("phi").text = "phi: "
	#current_level.hud.get_node("theta").text = "theta: "
#

#func instantiate_enemy(level_zero: bool, kill: bool) -> void:
	#hold_enemy = false
	#var enemy = ent_enemy_scene.instantiate()
	#if level_zero:
		#enemy.is_state_zero = true
		#if kill:
			#enemy.global_position = current_level.player.global_position + Vector2(0, -20)
		#else:
			#enemy.global_position = Vector2(ent_enemy_position, current_level.player.global_position.y + ent_enemy_y_displacement - 20)
	#else:
		#enemy.is_state_zero = false
		#if kill:		
			#enemy.global_position = current_level.player_2.global_position + Vector2(0, -20)
		#else:
			#enemy.global_position = Vector2(ent_enemy_position, current_level.player_2.global_position.y + ent_enemy_y_displacement - 20)
	#get_tree().current_scene.add_child(enemy)
	#enemy.add_to_group("entanglables")
	#
	#current_level.hud.get_node("enemy").visible = false

#func instantiate_gem_process():
	## Drop gem if holding
	#if hold_gem:
		#if cos(theta/2.0)**2 > 0.5:
			#instantiate_gem(true)
		#else:
			#instantiate_gem(false)
#
