extends Node
@onready var test: Node = $"."
@onready var tile_map_layer: TileMapLayer = $TileMapLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#if Input.is_action_just_pressed("Measure"):
		#tile_map_layer.hide()
		#tile_map_layer.queue_free()
	pass
	
	
	
