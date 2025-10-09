extends Node

## GAME MANAGER INSTANCE ##
var game_manager: Node = null

## LEVEL-2 OBJECT INSTANCES ##
@onready var hud: CanvasLayer = $HUD
@onready var player: CharacterBody2D = $Player
@onready var player_2: CharacterBody2D = $Player2
@onready var camera_2d: Camera2D = $Camera2D
@onready var camera0: Camera2D = $Player/Camera2D
@onready var camera1: Camera2D = $Player2/Camera2D
@onready var midground: TileMapLayer = $Tilemap/Midground
@onready var midground_2: TileMapLayer = $Tilemap/Midground2
@onready var time_taken: CanvasLayer = $TimeTaken
var start_layer_zero = true

func _ready() -> void:
	camera_2d.make_current()
	if start_layer_zero:
		camera_2d.global_position = camera0.global_position
	else:
		camera_2d.global_position = camera1.global_position

func set_game_manager(manager: Node):
	game_manager = manager
	game_manager_ready()

func game_manager_ready():
	if game_manager == null:
		return
	
	if game_manager.checkpoint_player_zero == null:
		game_manager.checkpoint_player_zero = false
		game_manager.checkpoint_position_0 = player.global_position
		game_manager.checkpoint_position_1 = player_2.global_position
		game_manager.level_start_time = Time.get_ticks_msec() / 1000.0
		if start_layer_zero:
			game_manager.set_state_zero()
		else:
			game_manager.set_state_one()
	
	hud.heart_label.text = str(game_manager.hearts)
	hud.coins_label.text = str(game_manager.score)
	
func load_next_level():
	game_manager.process_success()

func _process(delta: float) -> void:
	# this ensures process doesn't run before level is loaded
	if game_manager == null:
		return
	
	game_manager.delta_theta = delta*PI/2.0
	
	# superposition
	game_manager.process_superposition()
	
	# measurement
	if Input.is_action_pressed("Measure"):
		if !game_manager.measured and !game_manager.entangled_mode:
			game_manager.measure()
		elif !game_manager.measured and game_manager.entangled_mode:
			game_manager.measure_entangled()
	
	var time_taken = Time.get_ticks_msec() / 1000.0
	# update hud
	if !game_manager.entangled_mode:
		game_manager.process_update_hud(time_taken)
	else:
		game_manager.update_hud_entangle(time_taken)
	hud.get_node("carried_gate").text = str(game_manager.carried_gate)
	
	# update camera
	game_manager.process_camera()
	
	# interact for puzzle / teleportation
	game_manager.process_interact()
	
	# entangle
	game_manager.process_entanglement(time_taken)
	
	game_manager.process_pause()
