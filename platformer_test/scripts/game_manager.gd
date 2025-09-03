extends Node

var score = 0
var theta = 0
var delta_theta = 0

@export var hud: CanvasLayer

func _ready() -> void:
	score = 0


func add_point():
	# Update coins collected
	score += 1
	hud.get_node("CoinsLabel").text = str(score)
	

func _process(delta: float) -> void:
	
	# Update Theta
	delta_theta = delta*PI/2.0
	if Input.is_action_pressed("x_rotation"):
		theta += delta_theta
		if theta > 2 * PI:
			theta -= 2 * PI
	 # Sync movement
	
