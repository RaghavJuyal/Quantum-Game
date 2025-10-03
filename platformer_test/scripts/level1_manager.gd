extends Node

## GAME MANAGER INSTANCE ##
var game_manager: Node = null

## LEVEL-1 OBJECT INSTANCES ##
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

func _ready() -> void:
	camera_2d.make_current()
	camera_2d.global_position = camera1.global_position
	
	var interactables = [
		remove_gate_left_up, remove_gate_left_down, remove_gate_right_down, remove_gate_right_up,
		add_gate_left_up, add_gate_right_up, add_gate_left_down, add_gate_right_down,
		reset_circuit, run_circuit,
		z_gate, y_gate, x_gate, cnot_gate, hadamard_gate
	]
	for block in interactables:
		if block != null:
			block.add_to_group("interactables")

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

func _process(delta: float) -> void:
	# this ensures process doesn't run before level is loaded
	if game_manager == null:
		return
	
	game_manager.delta_theta = delta*PI/2.0
	
	# superposition
	game_manager.process_superposition()
	
	# measurement
	if Input.is_action_pressed("Measure"):
		if !game_manager.measured:
			game_manager.measure()
	
	# update hud
	game_manager.process_update_hud()
	hud.get_node("carried_gate").text = str(game_manager.carried_gate)
	
	# update camera
	game_manager.process_camera()
	
	# interact for puzzle / teleportation
	game_manager.process_interact(teleportation)
