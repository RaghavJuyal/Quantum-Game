extends Node2D
@onready var wire: Node2D = $"."
@export var middle_count: int = 5
@export_enum("Variant0", "Variant1") var begin_variant: int = 0

@onready var begin0 = $wire_begin_0
@onready var begin1 = $wire_begin_1
@onready var middle_template = $wire_middle
@onready var end_sprite = $wire_end

# Gate templates
@onready var gate_templates := {
	"X": $gate_X,
	"Y": $gate_Y,
	"Z": $gate_Z,
	"H": $gate_H,
	"control": $gate_control
}

var slots: Array[String] = []   # Each slot stores "middle" or gate type
var slot_nodes: Array[Node2D] = [] # Visual nodes corresponding to slots


func _ready() -> void:
	_hide_gate_templates()
	_init_slots()
	_update_wire_visuals()


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


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("x_rotation"):
		wire.add_gate_end("X")
	if Input.is_action_just_pressed("y_rotation"):
		wire.add_gate_end("Y")
	if Input.is_action_just_pressed("z_rotation"):
		wire.remove_gate_end()
	#if Input.is_action_just_pressed("Measure"):
		#wire.reset_gates()
