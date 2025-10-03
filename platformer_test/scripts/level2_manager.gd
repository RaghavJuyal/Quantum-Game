extends Node

## GAME MANAGER INSTANCE ##
var game_manager: Node = null

## LEVEL-2 OBJECT INSTANCES ##
@onready var hud: CanvasLayer = $HUD
@onready var player: CharacterBody2D = $Player
@onready var player_2: CharacterBody2D = $Player2
@onready var camera_2d: Camera2D = $Camera2D
@onready var camera0: Camera2D = $Player/Camera2D
@onready var camera1: Camera2D = $Player2/Camera2D
@onready var midground: TileMapLayer = $Tilemap/Midground
@onready var midground_2: TileMapLayer = $Tilemap/Midground2

@onready var puzzle: Node = $Puzzle
@onready var teleportation: Node2D = $Teleportation

@onready var gem: Node = $EntangledGem/Gem
@onready var ent_enemy: Node = $EntangleEnemy
@onready var ent_enemy_pressure: Node = $EntangleEnemy2
@onready var pressure_lock: Node = $PressureKeyLock/PressureLock
@onready var pressure_plate: Node = $PressureKeyLock/PressurePlate

## INTERACTABLE INSTANCES ##
@onready var remove_gate_left_up: Node = $Puzzle/Remove_gates/remove_gate_left_up
@onready var remove_gate_left_down: Node = $Puzzle/Remove_gates/remove_gate_left_down
@onready var remove_gate_right_down: Node = $Puzzle/Remove_gates/remove_gate_right_down
@onready var remove_gate_right_up: Node = $Puzzle/Remove_gates/remove_gate_right_up
@onready var add_gate_left_up: Node = $Puzzle/Add_gates/add_gate_left_up
@onready var add_gate_right_up: Node = $Puzzle/Add_gates/add_gate_right_up
@onready var add_gate_left_down: Node = $Puzzle/Add_gates/add_gate_left_down
@onready var add_gate_right_down: Node = $Puzzle/Add_gates/add_gate_right_down

@onready var run_circuit: RigidBody2D = $Puzzle/Other_blocks/run_circuit
@onready var reset_circuit: RigidBody2D = $Puzzle/Other_blocks/reset_circuit

@onready var z_gate: Node = $Puzzle/gates/z_gate
@onready var y_gate: Node = $Puzzle/gates/y_gate
@onready var x_gate: Node = $Puzzle/gates/x_gate
@onready var cnot_gate: Node = $Puzzle/gates/cnot_gate
@onready var hadamard_gate: Node = $Puzzle/gates/hadamard_gate

@onready var gem_block: Node = $"EntangledGem/Gem Block"
@onready var gem_obstacle: Node = $"EntangledGem/Gem Obstacle"

func _ready() -> void:
	camera_2d.make_current()
	camera_2d.global_position = camera1.global_position
	
	var interactables = [
		remove_gate_left_up, remove_gate_left_down, remove_gate_right_down, remove_gate_right_up,
		add_gate_left_up, add_gate_right_up, add_gate_left_down, add_gate_right_down,
		reset_circuit, run_circuit,
		z_gate, y_gate, x_gate, cnot_gate, hadamard_gate, 
		gem_block
	]
	for block in interactables:
		if block != null:
			block.add_to_group("interactables")
	
	var entanglables = [
		gem,
		ent_enemy,
		ent_enemy_pressure
	]
	for block in entanglables:
		if block != null:
			block.add_to_group("entanglables")
	pressure_plate.get_node("Area2D").pressed.connect(pressure_lock.open)
	pressure_plate.get_node("Area2D").released.connect(pressure_lock.close)

func set_game_manager(manager: Node):
	game_manager = manager
	game_manager_ready()

func game_manager_ready():
	if game_manager == null:
		return
	
	game_manager.checkpoint_player = player_2
	game_manager.checkpoint_position_0 = player.global_position
	game_manager.checkpoint_position_1 = player_2.global_position
	
	hud.heart_label.text = str(game_manager.hearts)
	hud.coins_label.text = str(game_manager.score)
	
	game_manager.set_state_one()

func handle_interaction(block:Node):
	match block.name:
		"add_gate_left_up": if game_manager.carried_gate!="": puzzle.add_gate_begin("up",game_manager.carried_gate); game_manager.carried_gate=""
		"add_gate_right_up": if game_manager.carried_gate!="": puzzle.add_gate_end("up",game_manager.carried_gate); game_manager.carried_gate=""
		"add_gate_left_down": if game_manager.carried_gate!="": puzzle.add_gate_begin("down",game_manager.carried_gate); game_manager.carried_gate=""
		"add_gate_right_down": if game_manager.carried_gate!="": puzzle.add_gate_end("down",game_manager.carried_gate); game_manager.carried_gate=""

		"remove_gate_left_up": game_manager.carried_gate = puzzle.remove_gate_begin("up")
		"remove_gate_right_up": game_manager.carried_gate = puzzle.remove_gate_end("up")
		"remove_gate_left_down": game_manager.carried_gate = puzzle.remove_gate_begin("down")
		"remove_gate_right_down": game_manager.carried_gate = puzzle.remove_gate_end("down")

		"reset_circuit": puzzle._reset_both()
		"run_circuit": 
			puzzle._run_circuit()

		"z_gate": game_manager.carried_gate="Z"
		"y_gate": game_manager.carried_gate="Y"
		"x_gate": game_manager.carried_gate="X"
		"cnot_gate": game_manager.carried_gate="CNOT"
		"hadamard_gate": game_manager.carried_gate="H"
		
		"Gem Block": _gem_block(block)

func _gem_block(block: Node) -> void:
	if (!game_manager.entangled_mode and game_manager.hold_gem):
		gem_obstacle.hide()
		gem_obstacle.queue_free()
		block.queue_free()
		
		game_manager.hold_gem = false
		hud.get_node("gem_carried").visible = false

func _process(delta: float) -> void:
	# this ensures process doesn't run before level is loaded
	if game_manager == null:
		return
	
	game_manager.delta_theta = delta*PI/2.0
	
	# superposition
	game_manager.process_superposition()
	
	# measurement
	if Input.is_action_pressed("Measure"):
		if !game_manager.measured and !game_manager.entangled_mode:
			game_manager.measure()
		elif !game_manager.measured and game_manager.entangled_mode:
			game_manager.measure_entangled()
	
	# update hud
	if !game_manager.entangled_mode:
		game_manager.process_update_hud()
	else:
		game_manager.update_hud_entangle()
	hud.get_node("carried_gate").text = str(game_manager.carried_gate)
	
	# update camera
	game_manager.process_camera()
	
	# interact for puzzle / teleportation
	game_manager.process_interact(teleportation)
	
	# entangle
	if Input.is_action_just_pressed("c_not"):
		var target = game_manager._is_on_entanglable(player)
		if target == null:
			target = game_manager._is_on_entanglable(player_2)
		
		if target != null:
			if target.name == "Gem":
				game_manager.hold_gem = true
			elif target.name == "EntangleEnemy":
				game_manager.hold_enemy = true
				game_manager.ent_enemy_x_position = target.global_position.x
			elif target.name == "EntangleEnemy2":
				game_manager.hold_enemy = true
				game_manager.ent_enemy_x_position = pressure_plate.global_position.x
				game_manager.ent_enemy_y_displacement = -20

			game_manager.entangled_mode = true
			# player is the control, object is the target
			game_manager.entangled_state = game_manager.calculate_entangled_state(target.is_state_zero)
			game_manager.entangled_probs = game_manager.calculate_entangled_probs()
			game_manager.edit_hud_entangle()
			
			player.color_sprite()
			player_2.color_sprite()
			target.queue_free()
