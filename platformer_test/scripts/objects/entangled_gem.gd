extends Node2D
@onready var gem_block: RigidBody2D = $"Gem Block"
@onready var gem_obstacle: TileMapLayer = $"Gem Obstacle"
@onready var game_manager: Node = get_tree().root.get_node("Game/GameManager")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#pass # Replace with function body.
	var interactables = [gem_block]
	for block in interactables:
		if block != null:
			block.add_to_group("interactables_entangle")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _gem_block(block: Node) -> void:
	if (!game_manager.entangled_mode and game_manager.hold_gem):
		gem_obstacle.hide()
		gem_obstacle.queue_free()
		block.queue_free()
		
		game_manager.hold_gem = false
		var current_level = game_manager.current_level
		current_level.hud.get_node("gem_carried").visible = false
