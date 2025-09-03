extends Node

var score = 0
var theta = 0
@onready var animated_sprite_2d: AnimatedSprite2D = $Player/AnimatedSprite2D
@onready var animated_sprite_2d2: AnimatedSprite2D = $Player2/AnimatedSprite2D


@export var hud: CanvasLayer

func _ready() -> void:
	score = 0
	animated_sprite_2d.self_modulate.a = 1.0
	animated_sprite_2d2.self_modulate.a = 0


func add_point():
	score += 1
	hud.get_node("CoinsLabel").text = str(score)
	


func _process(delta: float) -> void:
	if Input.is_action_pressed("x_rotation"):
		animated_sprite_2d.self_modulate.a = cos(theta/2.0)**2
		animated_sprite_2d2.self_modulate.a = sin(theta/2.0)**2
		theta += delta * PI / 2.0
		if theta > 2 * PI:
			theta -= 2 * PI
func theta_obtainer() -> float:
	return theta
