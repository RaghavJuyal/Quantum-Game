extends Node

# --- Load Complex number class ---
const Complex = preload("res://complex.gd")

# --- Nodes ---
@onready var wire_up: Node = $wire_up
@onready var wire_down: Node = $wire_down

@onready var remove_gate_left_up: Node = $Remove_gates/remove_gate_left_up
@onready var remove_gate_left_down: Node = $Remove_gates/remove_gate_left_down
@onready var remove_gate_right_down: Node = $Remove_gates/remove_gate_right_down
@onready var remove_gate_right_up: Node = $Remove_gates/remove_gate_right_up
@onready var add_gate_left_up: Node = $Add_gates/add_gate_left_up
@onready var add_gate_right_up: Node = $Add_gates/add_gate_right_up
@onready var add_gate_left_down: Node = $Add_gates/add_gate_left_down
@onready var add_gate_right_down: Node = $Add_gates/add_gate_right_down

@onready var puzzle_obstacle: TileMapLayer = $Puzzle_obstacle
@onready var game_manager: Node = get_tree().root.get_node("Game/GameManager")

@onready var run_circuit: Node = $run_circuit
@onready var reset_circuit: Node = $reset_circuit

@onready var z_gate: Node = $gates/z_gate
@onready var y_gate: Node = $gates/y_gate
@onready var x_gate: Node = $gates/x_gate
@onready var cnot_gate: Node = $gates/cnot_gate
@onready var hadamard_gate: Node = $gates/hadamard_gate

# --- Puzzle data ---
var circuit_sequence: Array = []         # Stores gate matrices in order
var initial_state: Array = []            # 4x1 vector of Complex numbers
var target_state: Array = []             # 4x1 vector of Complex numbers
var gate_matrices: Dictionary = {}       # Store 4x4 matrices for 2-qubit gates

func _ready() -> void:
	# Register interactables
	var s := 1.0 / sqrt(2.0)
	var interactables = [
		remove_gate_left_up, remove_gate_left_down, remove_gate_right_down, remove_gate_right_up,
		add_gate_left_up, add_gate_right_up, add_gate_left_down, add_gate_right_down,
		reset_circuit, run_circuit,
		z_gate, y_gate, x_gate, cnot_gate, hadamard_gate
	]
	for block in interactables:
		if block != null:
			block.add_to_group("interactables")

	# Initialize gate matrices
	_init_gate_matrices()

	# Example initial and target states
	initial_state = [
		Complex.new(1,0), Complex.new(0,0),
		Complex.new(0,0), Complex.new(0,0)
	]
	target_state = [
		Complex.new(0,0), Complex.new(0,0),
		Complex.new(-1,0), Complex.new(0,0)
	]

func _init_gate_matrices():
	var s := 1.0 / sqrt(2.0)

	gate_matrices = {
		# --- X ---
		"X_top": [
			Complex.new(0,0), Complex.new(0,0), Complex.new(1,0), Complex.new(0,0),
			Complex.new(0,0), Complex.new(0,0), Complex.new(0,0), Complex.new(1,0),
			Complex.new(1,0), Complex.new(0,0), Complex.new(0,0), Complex.new(0,0),
			Complex.new(0,0), Complex.new(1,0), Complex.new(0,0), Complex.new(0,0)
		],
		"X_bottom": [
			Complex.new(0,0), Complex.new(1,0), Complex.new(0,0), Complex.new(0,0),
			Complex.new(1,0), Complex.new(0,0), Complex.new(0,0), Complex.new(0,0),
			Complex.new(0,0), Complex.new(0,0), Complex.new(0,0), Complex.new(1,0),
			Complex.new(0,0), Complex.new(0,0), Complex.new(1,0), Complex.new(0,0)
		],

		# --- Y ---
		"Y_top": [
			Complex.new(0,0), Complex.new(0,0), Complex.new(0,-1), Complex.new(0,0),
			Complex.new(0,0), Complex.new(0,0), Complex.new(0,0), Complex.new(0,-1),
			Complex.new(0,1), Complex.new(0,0), Complex.new(0,0), Complex.new(0,0),
			Complex.new(0,0), Complex.new(0,1), Complex.new(0,0), Complex.new(0,0)
		],
		"Y_bottom": [
			Complex.new(0,0), Complex.new(0,-1), Complex.new(0,0), Complex.new(0,0),
			Complex.new(0,1), Complex.new(0,0), Complex.new(0,0), Complex.new(0,0),
			Complex.new(0,0), Complex.new(0,0), Complex.new(0,0), Complex.new(0,-1),
			Complex.new(0,0), Complex.new(0,0), Complex.new(0,1), Complex.new(0,0)
		],

		# --- Z ---
		"Z_top": [
			Complex.new(1,0), Complex.new(0,0), Complex.new(0,0), Complex.new(0,0),
			Complex.new(0,0), Complex.new(1,0), Complex.new(0,0), Complex.new(0,0),
			Complex.new(0,0), Complex.new(0,0), Complex.new(-1,0), Complex.new(0,0),
			Complex.new(0,0), Complex.new(0,0), Complex.new(0,0), Complex.new(-1,0)
		],
		"Z_bottom": [
			Complex.new(1,0), Complex.new(0,0), Complex.new(0,0), Complex.new(0,0),
			Complex.new(0,0), Complex.new(-1,0), Complex.new(0,0), Complex.new(0,0),
			Complex.new(0,0), Complex.new(0,0), Complex.new(1,0), Complex.new(0,0),
			Complex.new(0,0), Complex.new(0,0), Complex.new(0,0), Complex.new(-1,0)
		],

		# --- H ---
		"H_top": [
			Complex.new(s,0), Complex.new(0,0), Complex.new(s,0), Complex.new(0,0),
			Complex.new(0,0), Complex.new(s,0), Complex.new(0,0), Complex.new(s,0),
			Complex.new(s,0), Complex.new(0,0), Complex.new(-s,0), Complex.new(0,0),
			Complex.new(0,0), Complex.new(s,0), Complex.new(0,0), Complex.new(-s,0)
		],
		"H_bottom": [
			Complex.new(s,0), Complex.new(s,0), Complex.new(0,0), Complex.new(0,0),
			Complex.new(s,0), Complex.new(-s,0), Complex.new(0,0), Complex.new(0,0),
			Complex.new(0,0), Complex.new(0,0), Complex.new(s,0), Complex.new(s,0),
			Complex.new(0,0), Complex.new(0,0), Complex.new(s,0), Complex.new(-s,0)
		],

		# --- CNOT ---
		"CNOT_top": [
			Complex.new(1,0),Complex.new(0,0),Complex.new(0,0),Complex.new(0,0),
			Complex.new(0,0),Complex.new(1,0),Complex.new(0,0),Complex.new(0,0),
			Complex.new(0,0),Complex.new(0,0),Complex.new(0,0),Complex.new(1,0),
			Complex.new(0,0),Complex.new(0,0),Complex.new(1,0),Complex.new(0,0)
		],
		"CNOT_bottom": [
			Complex.new(1,0),Complex.new(0,0),Complex.new(0,0),Complex.new(0,0),
			Complex.new(0,0),Complex.new(0,0),Complex.new(1,0),Complex.new(0,0),
			Complex.new(0,0),Complex.new(1,0),Complex.new(0,0),Complex.new(0,0),
			Complex.new(0,0),Complex.new(0,0),Complex.new(0,0),Complex.new(1,0)
		]
	}

# --- Helper: get correct matrix name for wire ---
func _gate_name_for_wire(target:String, gate_type:String) -> String:
	if gate_type=="CNOT":
		return "CNOT_top" if target=="up" else "CNOT_bottom"
	else:
		return gate_type+"_"+("top" if target=="up" else "bottom")

# --- Add gates ---
func add_gate_begin(target:String, gate_type:String):
	_add_gate(target, gate_type, true)

func add_gate_end(target:String, gate_type:String):
	_add_gate(target, gate_type, false)

func _add_gate(target:String, gate_type:String, at_begin:bool):
	var gate_name = _gate_name_for_wire(target, gate_type)
	if gate_type=="CNOT":
		if target=="up":
			_insert_cnot(wire_up.slots, wire_down.slots, at_begin)
		else:
			_insert_cnot(wire_down.slots, wire_up.slots, at_begin)
	else:
		_insert_single_gate(target, gate_type, at_begin)

	if at_begin:
		circuit_sequence.insert(0, gate_matrices[gate_name].duplicate())
	else:
		circuit_sequence.append(gate_matrices[gate_name].duplicate())
	_trim_wire_capacity()
	_update_both_visuals()

func _insert_cnot(control_slots:Array, target_slots:Array, at_begin:bool):
	if at_begin:
		control_slots.insert(0,"control")
		target_slots.insert(0,"X")
	else:
		var idx = _find_leftmost_common_empty_index()
		if idx==-1: return
		control_slots[idx]="control"
		target_slots[idx]="X"

func _insert_single_gate(target:String, gate_type:String, at_begin:bool):
	var up_slots = wire_up.slots
	var down_slots = wire_down.slots
	if target=="up":
		if at_begin:
			up_slots.insert(0,gate_type)
			down_slots.insert(0,"middle")
		else:
			var idx = _find_leftmost_common_empty_index()
			if idx==-1: return
			up_slots[idx]=gate_type
	else:
		if at_begin:
			down_slots.insert(0,gate_type)
			up_slots.insert(0,"middle")
		else:
			var idx = _find_leftmost_common_empty_index()
			if idx==-1: return
			down_slots[idx]=gate_type

# --- Remove gates ---
func remove_gate_begin(target:String) -> String:
	var up_removed = wire_up.slots[0]
	var down_removed = wire_down.slots[0]

	# --- Only allow removal if actual gate is present ---
	if target == "up":
		if up_removed == "middle":
			return ""  # nothing to remove
	elif target == "down":
		if down_removed == "middle":
			return ""  # nothing to remove

	# --- Handle removal ---
	wire_up.slots.remove_at(0); wire_up.slots.append("middle")
	wire_down.slots.remove_at(0); wire_down.slots.append("middle")
	if circuit_sequence.size() > 0:
		circuit_sequence.pop_front()
	_update_both_visuals()
	return _picked_gate(up_removed, down_removed, target)

func remove_gate_end(target:String) -> String:
	# Find the rightmost non-middle/middle pair
	var idx_last := -1
	for i in range(wire_up.slots.size() - 1, -1, -1):
		if not (wire_up.slots[i] == "middle" and wire_down.slots[i] == "middle"):
			idx_last = i
			break

	if idx_last == -1:
		return ""  # no gates to remove

	var up_removed = wire_up.slots[idx_last]
	var down_removed = wire_down.slots[idx_last]

	# Only allow removal if selected wire has an actual gate
	if target == "up" and up_removed == "middle":
		return ""
	if target == "down" and down_removed == "middle":
		return ""

	# Just clear this slot instead of shifting
	wire_up.slots[idx_last] = "middle"
	wire_down.slots[idx_last] = "middle"

	# Keep circuit sequence in sync
	if circuit_sequence.size() > 0:
		circuit_sequence.pop_back()

	_update_both_visuals()
	return _picked_gate(up_removed, down_removed, target)

func _picked_gate(up, down, target) -> String:
	# CNOT special case
	if (up == "control" and down == "X") or (up == "X" and down == "control"):
		return "CNOT"

	# Normal case: return only the removed gate from the chosen wire
	if target == "up":
		return up if up != "middle" else ""
	else:
		return down if down != "middle" else ""

func _find_leftmost_common_empty_index() -> int:
	for i in range(wire_up.slots.size()):
		if wire_up.slots[i]=="middle" and wire_down.slots[i]=="middle":
			return i
	return -1

func _trim_wire_capacity():
	while wire_up.slots.size()>wire_up.middle_count: wire_up.slots.pop_back()
	while wire_down.slots.size()>wire_down.middle_count: wire_down.slots.pop_back()

func _update_both_visuals():
	if wire_up.has_method("_update_wire_visuals"): wire_up._update_wire_visuals()
	if wire_down.has_method("_update_wire_visuals"): wire_down._update_wire_visuals()
	
# Pretty-print a state vector (array of Complex)
func _state_to_string(state: Array) -> String:
	var parts: Array[String] = []
	for i in range(state.size()):
		var c: Complex = state[i]
		var amp_str := "%.3f" % c.re
		if abs(c.im) > 1e-6:  # show imaginary part only if nonzero
			var sign = "+" if c.im >= 0 else "-"
			amp_str += " %s %.3fi" % [sign, abs(c.im)]
		parts.append("|%d>: %s" % [i, amp_str])
	return "\n".join(parts)

# --- Run the circuit ---
func _run_circuit():
	var state = initial_state.duplicate()
	for g in circuit_sequence:
		state = _apply_gate(state, g)

	if _compare_states(state, target_state):
		puzzle_obstacle.hide()
		puzzle_obstacle.queue_free()
		print("Puzzle solved!")
		$correct.play()
	else:
		print("Failed. Final state:")
		print(_state_to_string(state))
		print("Target state:")
		print(_state_to_string(target_state))
		$incorrect.play()

func _apply_gate(state:Array, gate:Array) -> Array:
	var result = []
	for i in range(4):
		var sum = Complex.new(0,0)
		for j in range(4):
			sum = sum.add(gate[i*4+j].mul(state[j]))
		result.append(sum)
	return result

#func _compare_states(s1:Array, s2:Array, tol:float=1e-4) -> bool:
	#for i in range(4):
		#if not s1[i].equals(s2[i], tol): return false
	#return true

func _compare_states(s1:Array, s2:Array, tol:float=1e-4) -> bool:
	# Compute inner product <s2|s1>
	var inner = Complex.new(0,0)
	for i in range(4):
		inner = inner.add(s1[i].mul(s2[i].conjugate()))

	if inner.abs() < tol:
		# States are nearly orthogonal
		return false

	# Determine global phase factor
	var phase = Complex.new(inner.re/inner.abs(), inner.im/inner.abs())

	# Multiply s2 by phase and compare
	for i in range(4):
		var diff = s1[i].sub(s2[i].mul(phase))
		if diff.abs() > tol:
			return false

	return true

# --- Reset ---
func _reset_both():
	for i in range(wire_up.slots.size()): wire_up.slots[i]="middle"
	for i in range(wire_down.slots.size()): wire_down.slots[i]="middle"
	circuit_sequence.clear()
	_update_both_visuals()

# --- Interaction handler ---
func handle_interaction(block:Node):
	match block.name:
		"add_gate_left_up": if game_manager.carried_gate!="": add_gate_begin("up",game_manager.carried_gate); game_manager.carried_gate=""
		"add_gate_right_up": if game_manager.carried_gate!="": add_gate_end("up",game_manager.carried_gate); game_manager.carried_gate=""
		"add_gate_left_down": if game_manager.carried_gate!="": add_gate_begin("down",game_manager.carried_gate); game_manager.carried_gate=""
		"add_gate_right_down": if game_manager.carried_gate!="": add_gate_end("down",game_manager.carried_gate); game_manager.carried_gate=""

		"remove_gate_left_up": game_manager.carried_gate = remove_gate_begin("up")
		"remove_gate_right_up": game_manager.carried_gate = remove_gate_end("up")
		"remove_gate_left_down": game_manager.carried_gate = remove_gate_begin("down")
		"remove_gate_right_down": game_manager.carried_gate = remove_gate_end("down")

		"reset_circuit": _reset_both()
		"run_circuit": 
			_run_circuit()
			print("HI")

		"z_gate": game_manager.carried_gate="Z"
		"y_gate": game_manager.carried_gate="Y"
		"x_gate": game_manager.carried_gate="X"
		"cnot_gate": game_manager.carried_gate="CNOT"
		"hadamard_gate": game_manager.carried_gate="H"
