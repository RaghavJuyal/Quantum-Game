extends Node

var score = 0
var theta = 0
var delta_theta = 0
var measured: bool = false
var state = -1 # -1 default, 0 means |0> 1 means |1>
@export var hud: CanvasLayer
@onready var player: CharacterBody2D = $Player
@onready var player_2: CharacterBody2D = $Player2

func _ready() -> void:
	score = 0


func add_point():
	# Update coins collected
	score += 1
	hud.get_node("CoinsLabel").text = str(score)
	
func measure():
	if measured:
		return state
	var prob0 = cos(theta/2.0)**2
	var r = randf()
	if r < prob0:
		state = 0
		
	else:
		state = 1
	measured = true
	if state==0:
		theta = 0
	else:
		theta = PI
	return state
	
	
	
func _process(delta: float) -> void:
	
	# Update Theta
	delta_theta = delta*PI/2.0
	if Input.is_action_pressed("x_rotation"):
		if measured:
			measured = false
		theta += delta_theta
		if theta > 2 * PI:
			theta -= 2 * PI
		var prob0 = round((cos(theta/2.0)**2)*100)
		hud.get_node("Percent0").text = str(int(prob0))
		hud.get_node("Percent1").text = str(int(100-prob0))
	 # Sync movement
		
