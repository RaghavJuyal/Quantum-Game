extends Node

var score = 0
var current_layer = 1


@export var hud: CanvasLayer
@onready var player: CharacterBody2D = $"../Player"

func _ready() -> void:
	score = 0
	current_layer = player.get_current_layer()

func add_point():
	score += 1
	hud.get_node("CoinsLabel").text = str(score)
	
func update_name():

	if current_layer != null:
		hud.get_node("layerlabel").text = str(current_layer.name)

func _process(delta: float) -> void:
	#var current_layer = player.get_current_layer()
	if current_layer == null:
		current_layer = player.get_current_layer()
		if current_layer != null:
			hud.get_node("layerlabel").text = str(current_layer.name)
	#if current_layer != null:
		#var current_layer_name = current_layer.name
		#print(current_layer_name)
