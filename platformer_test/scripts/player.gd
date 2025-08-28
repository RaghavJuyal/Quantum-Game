extends CharacterBody2D


const SPEED = 100.0
const JUMP_VELOCITY = -250.0
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var layer1: TileMap = $"../layer1"
@onready var layer2: TileMap = $"../layer2"
@onready var game_manager: Node = %GameManager
@onready var platform: AnimatableBody2D = $"../Platform"


func get_current_layer():
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		if collision.get_normal().y < -0.7: # means floor, pointing up
			var collider = collision.get_collider()
			if collider is TileMap:
				return collider
			#if collider is AnimatableBody2D:
				#return collider
	return null

func _physics_process(delta: float) -> void:
	# Add the gravity.
	
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions. -1,0,1
	var direction := Input.get_axis("move_left", "move_right")
	if direction > 0:
		animated_sprite_2d.flip_h = false
	if direction < 0:
		animated_sprite_2d.flip_h = true
		
	if is_on_floor():
			
		if direction == 0:
			animated_sprite_2d.play("idle")
		else:
			animated_sprite_2d.play("run")
	else:
		animated_sprite_2d.play("jump")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
	
	if Input.is_action_just_pressed("x_rotation"):
		quantum_flip()
		game_manager.current_layer = get_current_layer()
		game_manager.update_name()


	

func quantum_flip() -> void:
	var current_layer: TileMap = get_current_layer()
	if current_layer == null:
		return
	if current_layer!= layer1 && current_layer != layer2:
		return
	# Decide which layer to flip into
	var target_layer
	if current_layer == layer1:
		target_layer = layer2
	else:
		target_layer = layer1
	#var target_layer: TileMap = (current_layer == layer1) if layer2 else layer1
	
	# Convert player’s global X position into the target tilemap’s local space
	var local_pos: Vector2 = target_layer.to_local(global_position)
	var cell_coords: Vector2i = target_layer.local_to_map(local_pos)

	# Now find the "ground" tile in that column
	var found_y: int = -10000
	for y in range(-100, 100): # scan vertically; adjust range for your level height
		var check_coords = Vector2i(cell_coords.x, y)
		var check_coords_above = Vector2i(cell_coords.x, y-1)
		
		if target_layer.get_cell_source_id(0, check_coords) != -1 && target_layer.get_cell_source_id(0,check_coords_above)==-1 && current_layer.get_cell_source_id(0,check_coords_above)==-1: # tile exists
			found_y = y
			break

	if found_y != -10000:
		# Place player just above the tile
		var tile_pos: Vector2 = target_layer.map_to_local(Vector2i(cell_coords.x, found_y))
		global_position = target_layer.to_global(tile_pos - Vector2(0, 16)) # offset to stand above
