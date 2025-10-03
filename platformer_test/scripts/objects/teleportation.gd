extends Node2D

# --- Nodes ---
@onready var teleport_start: RigidBody2D = $teleport_start
@onready var teleport_end: RigidBody2D = $teleport_end
@onready var wire_teleport_up: Node2D = $teleport_wires/wire_teleport_up
@onready var wire_teleport_mid: Node2D = $teleport_wires/wire_teleport_mid
@onready var wire_teleport_down: Node2D = $teleport_wires/wire_teleport_down
@onready var player: CharacterBody2D = $"../Player"
@onready var player_2: CharacterBody2D = $"../Player2"

@onready var game_manager: Node = get_tree().root.get_node("Game/GameManager")
@onready var hud: CanvasLayer = $"../HUD"
@onready var arrow: MeshInstance3D = hud.get_node("BlochSphere/SubViewport/arrow")

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
	_init_circuit()

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
	idx = _find_leftmost_common_empty_index()
	mid_slots[idx] = "control"        # control middle
	down_slots[idx] = "X"             # target bottom

	idx = _find_leftmost_common_empty_index()
	up_slots[idx] = "control"         # control top
	mid_slots[idx] = "X"              # target middle

	idx = _find_leftmost_common_empty_index()
	up_slots[idx] = "H"               # H top


	wire_teleport_up._update_wire_visuals()
	wire_teleport_mid._update_wire_visuals()
	wire_teleport_down._update_wire_visuals()

	
func _find_leftmost_common_empty_index() -> int:
	for i in range(wire_teleport_up.slots.size()):
		if wire_teleport_up.slots[i]=="middle" and wire_teleport_down.slots[i]=="middle" and wire_teleport_mid.slots[i] == "middle":
			return i
	return -1

func run_teleportation():
	await animate_teleport_circuit()
	var top_result = randi() % 2
	var mid_result = randi() % 2
	_apply_measurement_visual(wire_teleport_up, top_result)
	_apply_measurement_visual(wire_teleport_mid, mid_result)

	if top_result == 1:
		game_manager.rotate_z(-PI)
		arrow._rotate_z(-PI)
	if mid_result == 1:
		game_manager.rotate_x(-PI)
		arrow._rotate_x(-PI)
	var offset = 16
	player.global_position.x = teleport_end.global_position.x + offset
	player_2.global_position.x = teleport_end.global_position.x + offset
	await _animate_corrections(top_result, mid_result)

# Animate all wires column by column, then unpush
func animate_teleport_circuit(pause_time: float = 0.2) -> void:
	await _push_wires_column_by_column(pause_time)
	await get_tree().create_timer(0.5).timeout
	_unpush_all_wires_corrected()

# Push each column across all wires
func _push_wires_column_by_column(pause_time: float) -> void:
	var wires = [wire_teleport_up, wire_teleport_mid, wire_teleport_down]
	var num_slots = wires[0].slots.size()
	for i in range(num_slots):
		for w in wires:
			# push this slot
			w._push_slot(i)
		await get_tree().create_timer(pause_time).timeout

# Reset all wires without requiring begin0_default etc.
func _unpush_all_wires_corrected() -> void:
	var wires = [wire_teleport_up, wire_teleport_mid, wire_teleport_down]
	for w in wires:
		# Reset middles/gates
		w._unpush_all_slots()

func _apply_measurement_visual(wire: Node2D, result: int) -> void:
	# Hide the generic end
	wire.end_sprite.hide()
	# Show the correct measurement outcome
	if result == 0:
		wire.wire_end_0.show()
		wire.wire_end_1.hide()
	else:
		wire.wire_end_1.show()
		wire.wire_end_0.hide()

		
# Animate correction gates step by step
func _animate_corrections(top_result: int, mid_result: int) -> void:
	var steps := 30
	var delay := 0.04
	var delta := PI / steps

	# If second qubit measured as 1 → animate X rotation (do X first)
	if mid_result == 1:
		for i in range(steps):
			# apply a small positive increment each frame so total = +PI
			game_manager.rotate_x(delta)
			arrow._rotate_x(delta)
			await get_tree().create_timer(delay).timeout

	# If first qubit measured as 1 → animate Z rotation (do Z second)
	if top_result == 1:
		for i in range(steps):
			game_manager.rotate_z(delta)
			arrow._rotate_z(delta)
			await get_tree().create_timer(delay).timeout
