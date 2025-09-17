extends Node
@onready var wire_up: Node2D = $wire_up
@onready var wire_down: Node2D = $wire_down
@onready var remove_gate_left_up: RigidBody2D = $Remove_gates/remove_gate_left_up
@onready var remove_gate_left_down: RigidBody2D = $Remove_gates/remove_gate_left_down
@onready var remove_gate_right_down: RigidBody2D = $Remove_gates/remove_gate_right_down
@onready var remove_gate_right_up: RigidBody2D = $Remove_gates/remove_gate_right_up
@onready var add_gate_left_up: RigidBody2D = $Add_gates/add_gate_left_up
@onready var add_gate_right_up: RigidBody2D = $Add_gates/add_gate_right_up
@onready var add_gate_left_down: RigidBody2D = $Add_gates/add_gate_left_down
@onready var add_gate_right_down: RigidBody2D = $Add_gates/add_gate_right_down
@onready var puzzle_obstacle: TileMapLayer = $Puzzle_obstacle
@onready var game_manager: Node = get_tree().root.get_node("Game/GameManager")
@onready var run_circuit: RigidBody2D = $run_circuit
@onready var reset_circuit: RigidBody2D = $reset_circuit


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var interactables = [
		remove_gate_left_up, remove_gate_left_down, remove_gate_right_down, remove_gate_right_up,
		add_gate_left_up, add_gate_right_up, add_gate_left_down, add_gate_right_down,
		reset_circuit, run_circuit
	]

	# add them to the "interactables" group
	for block in interactables:
		if block != null:
			block.add_to_group("interactables")

func handle_interaction(block: Node) -> void:
	match block.name:
		"add_gate_left_up": 
			if game_manager.carried_gate != "" and game_manager.carried_gate != null:
				wire_up.add_gate_begin(game_manager.carried_gate)
				game_manager.carried_gate = ""
			else:
				print("No gate carried")
				
		"add_gate_right_up": 
			if game_manager.carried_gate != "" and game_manager.carried_gate != null:
				wire_up.add_gate_end(game_manager.carried_gate)
				game_manager.carried_gate = ""
			else:
				print("No gate carried")
		
		"remove_gate_left_up": 
			var gate = wire_up.remove_gate_begin()
			if gate!= "":
				game_manager.carried_gate = gate
			else:
				print("No gate to give")
		
		"remove_gate_right_up": 
			var gate = wire_up.remove_gate_end()
			if gate!= "":
				game_manager.carried_gate = gate
			else:
				print("No gate to give")
		
		"add_gate_left_down": 
			print("HI")
			print(game_manager.carried_gate)
			if game_manager.carried_gate != "" and game_manager.carried_gate != null:
				wire_down.add_gate_begin(game_manager.carried_gate)
				game_manager.carried_gate = ""
			else:
				print("No gate carried")
				
		"add_gate_right_down": 
			if game_manager.carried_gate != ""and game_manager.carried_gate != null:
				wire_down.add_gate_end(game_manager.carried_gate)
				game_manager.carried_gate = ""
			else:
				print("No gate carried")
		
		"remove_gate_left_down": 
			var gate = wire_down.remove_gate_begin()
			if gate!= "":
				game_manager.carried_gate = gate
			else:
				print("No gate to give")
		
		"remove_gate_right_down": 
			var gate = wire_down.remove_gate_end()
			if gate!= "":
				game_manager.carried_gate = gate
			else:
				print("No gate to give")
		
		"reset_circuit":
			wire_up.reset_gates()
			wire_down.reset_gates()
		
				

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
