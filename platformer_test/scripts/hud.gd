extends CanvasLayer

@onready var coins_label: Label = $CoinsLabel

func _ready() -> void:
	coins_label.text = str(0)
