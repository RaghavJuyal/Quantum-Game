extends Node2D

@onready var entangle_enemy: Area2D = $EntangleEnemy
@onready var game_manager: Node = get_tree().root.get_node("Game/GameManager")
@export var is_state_zero = false
var ent_enemy_x_position = 0

var ent_enemy_scene: PackedScene = preload("res://scenes/objects/entangle_enemy.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	entangle_enemy.add_to_group("entanglables")
	entangle_enemy.is_state_zero = is_state_zero

func handle_entanglement(target):
	game_manager.hold_enemy = target.get_parent()
	ent_enemy_x_position = target.global_position.x

func instantiate_enemy(level_zero: bool, kill: bool) -> void:
	var enemy = ent_enemy_scene.instantiate()
	var current_level = game_manager.current_level
	var parent = game_manager.hold_enemy
	if level_zero:
		enemy.is_state_zero = true
		if kill:
			enemy.global_position = current_level.player.global_position + Vector2(0, -20) - parent.global_position
		else:
			enemy.global_position = Vector2(ent_enemy_x_position, current_level.player.global_position.y - 20) - parent.global_position
	else:
		enemy.is_state_zero = false
		if kill:
			enemy.global_position = current_level.player_2.global_position + Vector2(0, -20) - parent.global_position
		else:
			enemy.global_position = Vector2(ent_enemy_x_position, current_level.player_2.global_position.y - 20) - parent.global_position
	enemy.add_to_group("entanglables")
	parent.add_child(enemy)
	
	game_manager.hold_enemy = null
	current_level.hud.get_node("enemy").visible = false
