extends Node

## GAME MANAGER INSTANCE ##
var game_manager: Node = null
const next_level = "res://scenes/level1.tscn"

## LEVEL-0 OBJECT INSTANCES ##
@onready var hud: CanvasLayer = $HUD
@onready var player: CharacterBody2D = $Player
@onready var player_2: CharacterBody2D = $Player2
@onready var camera_2d: Camera2D = $Camera2D
@onready var camera0: Camera2D = $Player/Camera2D
@onready var camera1: Camera2D = $Player2/Camera2D
@onready var midground: TileMapLayer = $Tilemap/Midground
@onready var midground_2: TileMapLayer = $Tilemap/Midground2

func _ready() -> void:
	camera_2d.make_current()
	camera_2d.global_position = camera1.global_position

func set_game_manager(manager: Node):
	game_manager = manager
	game_manager_ready()

func game_manager_ready():
	if game_manager == null:
		return
	
	game_manager.checkpoint_player = player_2
	game_manager.checkpoint_position_0 = player.global_position
	game_manager.checkpoint_position_1 = player_2.global_position
	
	hud.heart_label.text = str(game_manager.hearts)
	hud.coins_label.text = str(game_manager.score)
	
	game_manager.set_state_one()

func load_next_level():
	game_manager.load_level(next_level)

func _process(delta: float) -> void:
	# this ensures process doesn't run before level is loaded
	if game_manager == null:
		return
	
	game_manager.delta_theta = delta*PI/2.0
	
	# superposition
	game_manager.process_superposition()
	
	# measurement
	if Input.is_action_pressed("Measure"):
		if !game_manager.measured:
			game_manager.measure()
	
	# update hud
	game_manager.process_update_hud()
	
	# update camera
	game_manager.process_camera()
