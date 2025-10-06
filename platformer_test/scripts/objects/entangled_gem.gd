extends Node2D

var gem_scene: PackedScene = preload("res://scenes/objects/gem.tscn")

@onready var gem_block: RigidBody2D = $"Gem Block"
@onready var gem_obstacle: TileMapLayer = $"Gem Obstacle"
@onready var game_manager: Node = get_tree().root.get_node("Game/GameManager")
@export var is_state_zero = false
@onready var gem: Area2D = $Gem

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#pass # Replace with function body.
	var interactables = [gem_block]
	gem.is_state_zero = is_state_zero
	for block in interactables:
		if block != null:
			block.add_to_group("interactables_entangle")
	gem.add_to_group("entanglables")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _gem_block(block: Node) -> void:
	if (!game_manager.entangled_mode and game_manager.hold_gem):
		gem_obstacle.hide()
		gem_obstacle.queue_free()
		block.queue_free()
		var sound_player = get_node_or_null("ObstacleRemoved")
		if sound_player and not sound_player.playing:
			sound_player.play()
		
		game_manager.hold_gem = null
		var current_level = game_manager.current_level
		current_level.hud.get_node("gem_carried").visible = false

func handle_entanglement(target):
	game_manager.hold_gem = target.get_parent()

func instantiate_gem(level_zero: bool) -> void:
	var gem = gem_scene.instantiate()
	var current_level = game_manager.current_level
	var parent = game_manager.hold_gem
	if level_zero:
		gem.is_state_zero = true
		gem.global_position = current_level.player.global_position + Vector2(0, -10) - parent.global_position
	else:
		gem.is_state_zero = false
		gem.global_position = current_level.player_2.global_position + Vector2(0, -10) - parent.global_position
	gem.add_to_group("entanglables")
	parent.add_child(gem)
	
	game_manager.hold_gem = null
	current_level.hud.get_node("gem_carried").visible = false

func instantiate_gem_process():
	if cos(game_manager.theta/2.0)**2 > 0.5:
		instantiate_gem(true)
	else:
		instantiate_gem(false)
