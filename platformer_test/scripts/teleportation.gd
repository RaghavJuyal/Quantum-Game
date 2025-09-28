extends Node2D

# --- Nodes ---
@onready var teleport_start: RigidBody2D = $teleport_start
@onready var teleport_end: RigidBody2D = $teleport_end
@onready var wire_teleport_up: Node2D = $wire_teleport_up
@onready var wire_teleport_mid: Node2D = $wire_teleport_mid
@onready var wire_teleport_down: Node2D = $wire_teleport_down

@onready var game_manager: Node = get_tree().root.get_node("Game/GameManager")

# --- Quantum state ---
var initial_state: Array = []  # 8x1 vector of Complex
var current_state: Array = []
var gate_matrices: Dictionary = {}
var circuit_sequence: Array = ["H_middle","CNOT_middle_bottom","CNOT_top_middle","H_top"]  # 3-qubit gates as 8x8 matrices

var player_on_start: bool = false
var is_slots = false
# --- Input handling ---

func _ready() -> void:
	teleport_start.add_to_group("teleport_interact")
	_init_state()
	_init_gate_matrices()
	_init_circuit()
	#call_deferred("_init_circuit")
	
		
	

# --- Initialize 3-qubit state |ψ> ⊗ |00> ---
func _init_state() -> void:
	var theta = game_manager.theta
	var phi = game_manager.phi
	var alpha = Complex.new(cos(theta/2), 0)
	var beta = Complex.from_polar(sin(theta/2), phi)
	initial_state = [
		alpha, beta,           # top qubit = player
		Complex.new(0,0), Complex.new(0,0),
		Complex.new(0,0), Complex.new(0,0),
		Complex.new(0,0), Complex.new(0,0)
	]
	current_state = initial_state.duplicate(true)

# --- Gate matrices for teleportation (3 qubits, 8x8) ---
func _init_gate_matrices() -> void:
	var s = 1.0 / sqrt(2.0)
	gate_matrices = {}

	# --- Hadamard on top qubit ---
	gate_matrices["H_top"] = [
		Complex.new(s,0),Complex.new(0,0),Complex.new(0,0),Complex.new(0,0),Complex.new(s,0),Complex.new(0,0),Complex.new(0,0),Complex.new(0,0),
		Complex.new(0,0),Complex.new(s,0),Complex.new(0,0),Complex.new(0,0),Complex.new(0,0),Complex.new(s,0),Complex.new(0,0),Complex.new(0,0),
		Complex.new(0,0),Complex.new(0,0),Complex.new(s,0),Complex.new(0,0),Complex.new(0,0),Complex.new(0,0),Complex.new(s,0),Complex.new(0,0),
		Complex.new(0,0),Complex.new(0,0),Complex.new(0,0),Complex.new(s,0),Complex.new(0,0),Complex.new(0,0),Complex.new(0,0),Complex.new(s,0),
		Complex.new(s,0),Complex.new(0,0),Complex.new(0,0),Complex.new(0,0),Complex.new(-s,0),Complex.new(0,0),Complex.new(0,0),Complex.new(0,0),
		Complex.new(0,0),Complex.new(s,0),Complex.new(0,0),Complex.new(0,0),Complex.new(0,0),Complex.new(-s,0),Complex.new(0,0),Complex.new(0,0),
		Complex.new(0,0),Complex.new(0,0),Complex.new(s,0),Complex.new(0,0),Complex.new(0,0),Complex.new(0,0),Complex.new(-s,0),Complex.new(0,0),
		Complex.new(0,0),Complex.new(0,0),Complex.new(0,0),Complex.new(s,0),Complex.new(0,0),Complex.new(0,0),Complex.new(0,0),Complex.new(-s,0)
	]

	# --- Hadamard on middle qubit ---
	gate_matrices["H_middle"] = [
		Complex.new(s,0),Complex.new(0,0),Complex.new(s,0),Complex.new(0,0),Complex.new(0,0),Complex.new(0,0),Complex.new(0,0),Complex.new(0,0),
		Complex.new(0,0),Complex.new(s,0),Complex.new(0,0),Complex.new(s,0),Complex.new(0,0),Complex.new(0,0),Complex.new(0,0),Complex.new(0,0),
		Complex.new(s,0),Complex.new(0,0),Complex.new(-s,0),Complex.new(0,0),Complex.new(0,0),Complex.new(0,0),Complex.new(0,0),Complex.new(0,0),
		Complex.new(0,0),Complex.new(s,0),Complex.new(0,0),Complex.new(-s,0),Complex.new(0,0),Complex.new(0,0),Complex.new(0,0),Complex.new(0,0),
		Complex.new(0,0),Complex.new(0,0),Complex.new(0,0),Complex.new(0,0),Complex.new(s,0),Complex.new(0,0),Complex.new(s,0),Complex.new(0,0),
		Complex.new(0,0),Complex.new(0,0),Complex.new(0,0),Complex.new(0,0),Complex.new(0,0),Complex.new(s,0),Complex.new(0,0),Complex.new(s,0),
		Complex.new(0,0),Complex.new(0,0),Complex.new(0,0),Complex.new(0,0),Complex.new(s,0),Complex.new(0,0),Complex.new(-s,0),Complex.new(0,0),
		Complex.new(0,0),Complex.new(0,0),Complex.new(0,0),Complex.new(0,0),Complex.new(0,0),Complex.new(s,0),Complex.new(0,0),Complex.new(-s,0)
	]

	# --- CNOT top->middle ---
	gate_matrices["CNOT_top_middle"] = [
		Complex.new(1,0),Complex.new(0,0),Complex.new(0,0),Complex.new(0,0),Complex.new(0,0),Complex.new(0,0),Complex.new(0,0),Complex.new(0,0),
		Complex.new(0,0),Complex.new(1,0),Complex.new(0,0),Complex.new(0,0),Complex.new(0,0),Complex.new(0,0),Complex.new(0,0),Complex.new(0,0),
		Complex.new(0,0),Complex.new(0,0),Complex.new(0,0),Complex.new(1,0),Complex.new(0,0),Complex.new(0,0),Complex.new(0,0),Complex.new(0,0),
		Complex.new(0,0),Complex.new(0,0),Complex.new(1,0),Complex.new(0,0),Complex.new(0,0),Complex.new(0,0),Complex.new(0,0),Complex.new(0,0),
		Complex.new(0,0),Complex.new(0,0),Complex.new(0,0),Complex.new(0,0),Complex.new(1,0),Complex.new(0,0),Complex.new(0,0),Complex.new(0,0),
		Complex.new(0,0),Complex.new(0,0),Complex.new(0,0),Complex.new(0,0),Complex.new(0,0),Complex.new(1,0),Complex.new(0,0),Complex.new(0,0),
		Complex.new(0,0),Complex.new(0,0),Complex.new(0,0),Complex.new(0,0),Complex.new(0,0),Complex.new(0,0),Complex.new(0,0),Complex.new(1,0),
		Complex.new(0,0),Complex.new(0,0),Complex.new(0,0),Complex.new(0,0),Complex.new(0,0),Complex.new(0,0),Complex.new(1,0),Complex.new(0,0)
	]

	# --- CNOT middle->bottom ---
	gate_matrices["CNOT_middle_bottom"] = [
		Complex.new(1,0),Complex.new(0,0),Complex.new(0,0),Complex.new(0,0),Complex.new(0,0),Complex.new(0,0),Complex.new(0,0),Complex.new(0,0),
		Complex.new(0,0),Complex.new(1,0),Complex.new(0,0),Complex.new(0,0),Complex.new(0,0),Complex.new(0,0),Complex.new(0,0),Complex.new(0,0),
		Complex.new(0,0),Complex.new(0,0),Complex.new(1,0),Complex.new(0,0),Complex.new(0,0),Complex.new(0,0),Complex.new(0,0),Complex.new(0,0),
		Complex.new(0,0),Complex.new(0,0),Complex.new(0,0),Complex.new(1,0),Complex.new(0,0),Complex.new(0,0),Complex.new(0,0),Complex.new(0,0),
		Complex.new(0,0),Complex.new(0,0),Complex.new(0,0),Complex.new(0,0),Complex.new(1,0),Complex.new(0,0),Complex.new(0,0),Complex.new(0,0),
		Complex.new(0,0),Complex.new(0,0),Complex.new(0,0),Complex.new(0,0),Complex.new(0,0),Complex.new(1,0),Complex.new(0,0),Complex.new(0,0),
		Complex.new(0,0),Complex.new(0,0),Complex.new(0,0),Complex.new(0,0),Complex.new(0,0),Complex.new(0,0),Complex.new(0,0),Complex.new(1,0),
		Complex.new(0,0),Complex.new(0,0),Complex.new(0,0),Complex.new(0,0),Complex.new(0,0),Complex.new(0,0),Complex.new(1,0),Complex.new(0,0)
	]
func _init_circuit():
	var up_slots = wire_teleport_up.slots
	var mid_slots = wire_teleport_mid.slots 
	var down_slots = wire_teleport_down.slots 

	# Clear all slots first
	for i in range(up_slots.size()):
		up_slots[i] = "middle"
		mid_slots[i] = "middle"
		down_slots[i] = "middle"

	# Fill the teleportation gates in order
	var idx = _find_leftmost_common_empty_index()
	mid_slots[idx] = "H"              # H middle
	#_trim_wire_capacity()
	idx = _find_leftmost_common_empty_index()
	mid_slots[idx] = "control"        # control middle
	down_slots[idx] = "X"             # target bottom
	#_trim_wire_capacity()
	idx = _find_leftmost_common_empty_index()
	up_slots[idx] = "control"         # control top
	mid_slots[idx] = "X"              # target middle
	#_trim_wire_capacity()
	idx = _find_leftmost_common_empty_index()
	up_slots[idx] = "H"               # H top
	#_trim_wire_capacity()

	# Update visuals once
	wire_teleport_up._update_wire_visuals()
	wire_teleport_mid._update_wire_visuals()
	wire_teleport_down._update_wire_visuals()

	
func _trim_wire_capacity():
	while wire_teleport_down.slots.size()>wire_teleport_down.middle_count: wire_teleport_down.slots.pop_back()
	while wire_teleport_mid.slots.size()>wire_teleport_mid.middle_count: wire_teleport_mid.slots.pop_back()
	while wire_teleport_up.slots.size()>wire_teleport_up.middle_count: wire_teleport_up.slots.pop_back()
	
func _find_leftmost_common_empty_index() -> int:
	for i in range(wire_teleport_up.slots.size()):
		if wire_teleport_up.slots[i]=="middle" and wire_teleport_down.slots[i]=="middle" and wire_teleport_mid.slots[i] == "middle":
			return i
	return -1
func _apply_gate(state:Array, gate:Array) -> Array:
	var result = []
	for i in range(8):
		var sum = Complex.new(0,0)
		for j in range(8):
			sum = sum.add(gate[i*8+j].mul(state[j]))
		result.append(sum)
	return result
# --- Setup circuit visually ---
