extends CharacterBody2D

const SPEED = 100.0
const JUMP_VELOCITY = -250.0

var coyote_time = 0
var coyote_time_max = 0.1
var can_jump = false
var stop = false

@export var is_state_zero: bool = true
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var game_manager: Node = get_tree().root.get_node("Game/GameManager")
@onready var interact_area: Area2D = $interact_area

func _ready() -> void:
	if is_state_zero:
		animated_sprite_2d.self_modulate.a = 1
	else:
		animated_sprite_2d.self_modulate.a = 0

func _is_on_interactable():
	for body in interact_area.get_overlapping_bodies():
		if body.is_in_group("interactables"):
			return true
	return false

func color_sprite():
	animated_sprite_2d.modulate = Color(0.7, 0.3, 0.9, 0.8)

func uncolor_sprite():
	animated_sprite_2d.modulate = Color(1, 1, 1, 1)

func _physics_process(delta: float) -> void:
	if !stop:
		# Add the gravity.
		if not is_on_floor():
			if can_jump and coyote_time <= coyote_time_max:
				coyote_time += delta
			velocity += get_gravity() * delta
		# Handle jump.
		if Input.is_action_just_pressed("jump") and (is_on_floor() or coyote_time < coyote_time_max) and can_jump:
			can_jump = false
			coyote_time = 0
			velocity.y = JUMP_VELOCITY
		
		# Get the input direction and handle the movement/deceleration.
		# -1 means left,0 means no movement, 1 means right
		var direction := Input.get_axis("move_left", "move_right")
		if direction > 0:
			animated_sprite_2d.flip_h = false
		if direction < 0:
			animated_sprite_2d.flip_h = true
		
		if is_on_floor():
			can_jump = true
			coyote_time = 0
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
		if game_manager.current_level:
			game_manager.sync_players()
		if !game_manager.entangled_mode:
			var theta = game_manager.theta
			if is_state_zero:
				animated_sprite_2d.self_modulate.a = cos(theta/2.0)**2
			else:
				animated_sprite_2d.self_modulate.a = sin(theta/2.0)**2
		else: 
			if is_state_zero:
				animated_sprite_2d.self_modulate.a = game_manager.entangled_probs[0]+game_manager.entangled_probs[1]
			else:
				animated_sprite_2d.self_modulate.a = game_manager.entangled_probs[2]+game_manager.entangled_probs[3]
