extends Node2D
@onready var entangle_enemy: Area2D = $EntangleEnemy
@onready var game_manager: Node = get_tree().root.get_node("Game/GameManager")
@export var is_state_zero = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	entangle_enemy.add_to_group("entanglables")
	entangle_enemy.is_state_zero = is_state_zero


func handle_entanglement(target):
	game_manager.hold_enemy = true
	game_manager.ent_enemy_x_position = target.global_position.x
