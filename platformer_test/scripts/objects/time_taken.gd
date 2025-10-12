extends CanvasLayer

@onready var label_2: Label = $Label2


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	label_2.text = str(0) + " s"
