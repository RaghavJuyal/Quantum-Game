extends Node2D
@onready var wire: Node2D = $"."
@export var middle_count: int = 5
@export_enum("Variant0", "Variant1","blank") var begin_variant: int = 0

@onready var begin0 = $wire_begin_0
@onready var begin1 = $wire_begin_1
@onready var middle_template = $wire_middle
@onready var end_sprite = $wire_end
@onready var wire_begin_1_pushed: Sprite2D = $wire_begin_1_pushed
@onready var wire_end_pushed: Sprite2D = $wire_end_pushed
@onready var wire_middle_pushed: Sprite2D = $wire_middle_pushed
@onready var wire_begin_0_pushed: Sprite2D = $wire_begin_0_pushed
@onready var wire_begin_blank: Sprite2D = $wire_begin_blank
@onready var wire_begin_blank_pushed: Sprite2D = $wire_begin_blank_pushed
@onready var wire_end_1: Sprite2D = $wire_end_1
@onready var wire_end_0: Sprite2D = $wire_end_0
#@onready var teleportation: Node = get_tree().root.get_node("Game/GameManager/Teleportation")

# Gate templates
@onready var gate_templates := {
	"X": $gate_X,
	"X_pushed": $gate_X_pushed,
	"H": $gate_H,
	"H_pushed": $gate_H_pushed,
	"control": $gate_control,
	"control_pushed": $gate_control_pushed
	
}

var slots: Array[String] = []   # Each slot stores "middle" or gate type
var slot_nodes: Array[Node2D] = [] # Visual nodes corresponding to slots


func _ready() -> void:
	_hide_gate_templates()
	_init_slots()
	_update_wire_visuals()
	wire_begin_0_pushed.hide()
	wire_begin_1_pushed.hide()
	wire_end_pushed.hide()
	wire_middle_pushed.hide()
	wire_begin_blank_pushed.hide()
	#teleportation._init_circuit()

func _hide_gate_templates() -> void:
	for gate in gate_templates.values():
		gate.hide()

func _init_slots() -> void:
	slots.clear()
	slot_nodes.clear()
	for i in range(middle_count):
		slots.append("middle")
		var middle_copy = middle_template.duplicate()
		middle_copy.show()
		add_child(middle_copy)
		slot_nodes.append(middle_copy)

func _update_wire_visuals() -> void:
	begin0.visible = (begin_variant == 0)
	begin1.visible = (begin_variant == 1)
	wire_begin_blank.visible = (begin_variant == 2)
	var mid_w = middle_template.texture.get_width()/2
	var base = middle_template.position

	for i in range(slots.size()):
		var node = slot_nodes[i]
		var slot_type = slots[i]

		# Remove previous node
		if node:
			node.queue_free()

		if slot_type == "middle":
			node = middle_template.duplicate()
		else:
			node = gate_templates[slot_type].duplicate()

		node.show()
		node.position = base + Vector2((i+1) * mid_w, 0)
		add_child(node)
		slot_nodes[i] = node
	middle_template.hide() 
	end_sprite.position = base + Vector2((middle_count + 1) * mid_w, 0)
	wire_end_0.position = end_sprite.position
	wire_end_1.position = end_sprite.position
	wire_end_0.hide()
	wire_end_1.hide()

# --- Gate management ---
func add_gate_begin(gate_type: String) -> void:
	if _is_full():
		return

	slots.insert(0, gate_type)
	if slots.size() > middle_count:
		slots.pop_back()

	_update_wire_visuals()

func add_gate_end(gate_type: String) -> void:
	if _is_full():
		return

	# Find the last middle slot
	for i in range(slots.size()):
		if slots[i] == "middle":
			slots[i] = gate_type
			break

	_update_wire_visuals()

func remove_gate_begin() -> void:
	# Only remove if the first slot is a gate
	if slots[0] != "middle":
		# Remove first element and push a "middle" at the end
		slots.remove_at(0)
		slots.append("middle")
		_update_wire_visuals()

func remove_gate_end() -> void:
	for i in range(slots.size() - 1, -1, -1):
		if slots[i] != "middle":
			slots[i] = "middle"
			break
	_update_wire_visuals()

func reset_gates() -> void:
	for i in range(slots.size()):
		slots[i] = "middle"
	_update_wire_visuals()

# --- Helpers ---
func _is_full() -> bool:
	return slots.all(func(s): return s != "middle")

# returns index of first non-middle (leftmost), or -1 if none
func first_gate_index() -> int:
	for i in range(slots.size()):
		if slots[i] != "middle":
			return i
	return -1

# returns index of last non-middle (rightmost), or -1 if none
func last_gate_index() -> int:
	for i in range(slots.size() - 1, -1, -1):
		if slots[i] != "middle":
			return i
	return -1

# remove gate at a specific index; if shift_left==true, remove and push a "middle" at end;
# if shift_left==false, remove and insert "middle" at index 0 (keeps packing consistent).
# returns the removed gate type or "" if nothing removed.
func remove_gate_at_index(index:int, shift_left:bool=true) -> String:
	if index < 0 or index >= slots.size():
		return ""
	var g = slots[index]
	if g == "middle":
		return ""
	if shift_left:
		slots.remove_at(index)
		slots.append("middle")
	else:
		# remove and insert a middle at front so things remain packed to the right
		slots.remove_at(index)
		slots.insert(0, "middle")
	_update_wire_visuals()
	return g

# set a gate at a specific index (used for adding a CNOT to both wires)
# returns true on success, false if index invalid or occupied
func set_gate_at_index(index:int, gate_type:String) -> bool:
	if index < 0 or index >= slots.size():
		return false
	if slots[index] != "middle":
		return false
	slots[index] = gate_type
	_update_wire_visuals()
	return true

# (Optional) helper: check if slot index is free
func is_slot_empty(index:int) -> bool:
	if index < 0 or index >= slots.size():
		return false
	return slots[index] == "middle"

# --- New functions for animations ---

# Run the animation: push each column one by one
func run_circuit_animation(pause_time: float = 0.3) -> void:
	await _push_slots_step_by_step(pause_time)
	# after everything pushed, you can wait for simulation result
	# then unpush all
	await get_tree().create_timer(0.5).timeout
	_unpush_all_slots()

# Push slots one at a time
func _push_slots_step_by_step(pause_time: float) -> void:
	for i in range(slots.size()):
		_push_slot(i)
		await get_tree().create_timer(pause_time).timeout

# Switch a slot to pushed version if it has one
func _push_slot(index: int) -> void:
	var g = slots[index]
	if g == "middle":
		# push the wire segment
		_replace_slot_sprite(index, "middle_pushed")
	elif gate_templates.has(g + "_pushed"):
		_replace_slot_sprite(index, g + "_pushed")

# Reset all slots back to normal
func _unpush_all_slots() -> void:
	for i in range(slots.size()):
		var g = slots[i]
		if g == "middle" or g.ends_with("_pushed"):
			_replace_slot_sprite(i, "middle")
		else:
			_replace_slot_sprite(i, g)

# Replace a slot's sprite with another variant
func _replace_slot_sprite(index: int, new_type: String) -> void:
	var node = slot_nodes[index]
	if node:
		node.queue_free()
	var base = middle_template.position
	var mid_w = middle_template.texture.get_width()/2
	var node_new: Node2D
	if new_type == "middle" or new_type == "middle_pushed":
		node_new = middle_template.duplicate() if new_type == "middle"  else wire_middle_pushed.duplicate()
	else:
		node_new = gate_templates[new_type].duplicate()
	node_new.show()
	node_new.position = base + Vector2((index + 1) * mid_w, 0)
	add_child(node_new)
	slot_nodes[index] = node_new
	
func push_slot(index:int) -> void:
	if index < 0 or index >= slot_nodes.size():
		return
	var node = slot_nodes[index]
	match slots[index]:
		"middle":
			node.texture = wire_middle_pushed.texture
		"control":
			node.texture = gate_templates["control_pushed"].texture
		# for normal gates
		_:
			if gate_templates.has(slots[index] + "_pushed"):
				node.texture = gate_templates[slots[index] + "_pushed"].texture

func unpush_all() -> void:
	for i in range(slot_nodes.size()):
		var node = slot_nodes[i]
		match slots[i]:
			"middle": node.texture = middle_template.texture
			"control": node.texture = gate_templates["control"].texture
			_:
				if gate_templates.has(slots[i]):
					node.texture = gate_templates[slots[i]].texture
