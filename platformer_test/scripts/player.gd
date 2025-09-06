extends CharacterBody2D


const SPEED = 100.0
const JUMP_VELOCITY = -250.0
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var game_manager: Node = get_tree().root.get_node("Game/GameManager")
@export var is_state_zero: bool = true
#@export var leader: CharacterBody2D
@export var spawn_layer_y : float
var collision = null
func _ready() -> void:
	if is_state_zero:
		animated_sprite_2d.self_modulate.a = 1
	else:
		animated_sprite_2d.self_modulate.a = 0




func _physics_process(delta: float) -> void:
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	# Get the input direction and handle the movement/deceleration.
	# -1 means left,0 means no movement, 1 means right
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
	#collision = get_last_slide_collision()
	#if animated_sprite_2d.self_modulate.a <=1e-6:
	game_manager.sync_players()
	collision = null
	var theta = game_manager.theta
	if is_state_zero:
		animated_sprite_2d.self_modulate.a = cos(theta/2.0)**2
	else:
		animated_sprite_2d.self_modulate.a = sin(theta/2.0)**2
		



	
