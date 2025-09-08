extends Node

var score = 0
var theta = 0
var delta_theta = 0
var measured: bool = false
var state = -1 # -1 default, 0 means |0> 1 means |1>
var allowed = true
@export var hud: CanvasLayer
@onready var player: CharacterBody2D = $Player
@onready var player_2: CharacterBody2D = $Player2
@onready var midground: TileMapLayer = $Tilemap/Midground
@onready var midground_2: TileMapLayer = $Tilemap/Midground2
@onready var camera_2d: Camera2D = $Camera2D
@onready var camera0: Camera2D = $Player/Camera2D
@onready var camera1: Camera2D = $Player2/Camera2D

func _ready() -> void:
	score = 0
	camera_2d.make_current()
	camera_2d.global_position = camera0.global_position


func add_point():
	# Update coins collected
	score += 1
	hud.get_node("CoinsLabel").text = str(score)
	
func measure():
	if measured:
		return state
	allowed = false
	var prob0 = cos(theta/2.0)**2
	var r = randf()
	if r < prob0:
		state = 0
		hud.get_node("Percent0").text = str(100.0)
		hud.get_node("Percent1").text = str(0.0)
		
	else:
		state = 1
		hud.get_node("Percent0").text = str(0.0)
		hud.get_node("Percent1").text = str(100.0)
	measured = true
	if state==0:
		theta = 0
		camera_2d.global_position = camera_2d.global_position.lerp(camera0.global_position,0.005)
	else:
		theta = PI
		camera_2d.global_position = camera_2d.global_position.lerp(camera1.global_position,0.005)
	return state
	
func find_safe_spawn(x_global: float, current_is_layer1: bool):
	var current_layer: TileMapLayer
	var target_layer: TileMapLayer
	if current_is_layer1:
		current_layer = midground
		target_layer = midground_2
	else:
		current_layer = midground_2
		target_layer = midground
	
	var local = target_layer.to_local(Vector2(x_global,0.0))
	var cell = target_layer.local_to_map(local)
	var cell_x = cell.x
	var used = target_layer.get_used_rect()
	
	if cell_x < used.position.x or cell_x >= used.position.x + used.size.x:
		return Vector2.INF
	
	var y_from = used.position.y - 2
	var y_to = used.position.y + used.size.y + 2
	for y in range(y_from, y_to):
		var ground = Vector2i(cell_x,y)
		var above = Vector2i(cell_x,y-1)
		
		if (target_layer.get_cell_source_id(ground) != -1) and (target_layer.get_cell_source_id(above) == -1) and (current_layer.get_cell_source_id(above) == -1):
			var tile_pos = target_layer.map_to_local(ground)
			return Vector2(x_global,target_layer.to_global(tile_pos).y)
	
	return Vector2.INF

func try_superposition(requester:CharacterBody2D)->bool:
	if not measured:
		return false
	var requester_is_layer_1 = requester==player
	var partner 
	if requester_is_layer_1:
		partner = player_2
	else:
		partner = player
	var spawn_at = find_safe_spawn(requester.global_position.x, requester_is_layer_1)
	if spawn_at == Vector2.INF:
		return false
	
	partner.global_position = spawn_at
	measured = false
	state = -1
	return true

func get_horizontal_blocked_distance(player):
	var total_blocked = 0.0
	for i in range(player.get_slide_collision_count()):
		var collision = player.get_slide_collision(i)
		var normal = collision.get_normal()
		# only consider horizontal collisions
		if abs(normal.x) > 0.7:
			# horizontal blocked, accumulate distance
			total_blocked += abs(collision.get_remainder().x)
	return total_blocked
	
func sync_players():
	# Skip collapsed players
	var active_players = []
	if player.animated_sprite_2d.self_modulate.a > 0.01:
		active_players.append(player)
	if player_2.animated_sprite_2d.self_modulate.a > 0.01:
		active_players.append(player_2)

	if active_players.size() < 2:
		return  # nothing to sync
	
	# Determine blocked distances using collisions
	var dist_list = []
	for p in active_players:
		dist_list.append(get_horizontal_blocked_distance(p))

	# Leader = blocked player (larger distance)
	var leader
	var follower
	if dist_list[0] >= dist_list[1]:
		leader = active_players[0]
		follower = active_players[1]
	else:
		leader = active_players[1]
		follower = active_players[0]

# Snap follower X to leader
	follower.global_position.x = leader.global_position.x
	
	
func _process(delta: float) -> void:
	
	# Update Theta
	delta_theta = delta*PI/2.0
	if Input.is_action_pressed("x_rotation"):
		if measured:
			#measured = false
			var requester
			if state ==0:
				requester = player
			else:
				requester = player_2
			var ok = try_superposition(requester)
			if ok:
				theta += delta_theta
				if theta > 2 * PI:
					theta -= 2 * PI
				allowed = true
		else:
			theta += delta_theta
			if theta > 2 * PI:
				theta -= 2 * PI
		
		var prob0_raw = (cos(theta/2.0)**2)*100
		var prob0 = round(prob0_raw * 10.0) / 10.0
		var prob1 = round((100 - prob0) * 10.0) / 10.0

		if prob0 == 100.0:
			measured = true
			state = 0
			allowed = false
		elif prob0 == 0.0:
			measured = true
			state = 1
			allowed = false

		hud.get_node("Percent0").text = str(prob0)
		hud.get_node("Percent1").text = str(prob1)
		
	var alpha0 = player.get_node("AnimatedSprite2D").self_modulate.a
	var alpha1 = player_2.get_node("AnimatedSprite2D").self_modulate.a

	var target
	if alpha0>= alpha1:
		target = camera0
	else:
		target = camera1

	camera_2d.global_position = camera_2d.global_position.lerp(target.global_position,0.005)
	# problem with this is if one person dies they go down and so does the camera
	#camera_2d.global_position = camera_2d.global_position.lerp((camera0.global_position+camera1.global_position)/2.0,0.005)
	
	
	 # Sync movement
		
