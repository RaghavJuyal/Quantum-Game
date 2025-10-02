extends Node

## GAME MANAGER INSTANCE ##
var game_manager: Node = null

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

func _process(delta: float) -> void:
	# this ensures process doesn't run before level is loaded
	if game_manager == null:
		return
	
	game_manager.delta_theta = delta*PI/2.0
	
	# superposition logic
	if !game_manager.suppos_allowed:
		var requester
		if game_manager.state == 0:
			requester = player
		elif game_manager.state == 1:
			requester = player_2
		var ok = game_manager.try_superposition(requester)
		if ok:
			game_manager.suppos_allowed = true
	if game_manager.suppos_allowed:
		if Input.is_action_pressed("x_rotation"):
			if game_manager.measured:
				game_manager.state = -1
			game_manager.rotate_x(game_manager.delta_theta)
		if Input.is_action_pressed("y_rotation"):
			if game_manager.measured:
				game_manager.state = -1
			game_manager.rotate_y(game_manager.delta_theta)
		if Input.is_action_pressed("z_rotation"):
			if game_manager.measured:
				game_manager.state = -1
			game_manager.rotate_z(game_manager.delta_theta)
	
	# measurement
	if Input.is_action_pressed("Measure"):
		if !game_manager.measured:
			game_manager.measure()
	
	game_manager.update_hud()
	
	var alpha0 = player.get_node("AnimatedSprite2D").self_modulate.a
	var alpha1 = player_2.get_node("AnimatedSprite2D").self_modulate.a
	var camera_target
	if alpha0 >= alpha1:
		camera_target = camera0
	else:
		camera_target = camera1
	camera_2d.global_position = camera_2d.global_position.lerp(camera_target.global_position, 0.005)
