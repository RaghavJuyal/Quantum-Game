extends CanvasLayer

@onready var coins_label: Label = $CoinsLabel
@onready var zero_label: Label = $Percent0
@onready var one_label: Label = $Percent1

func _ready() -> void:
	coins_label.text = str(0) # Intial number of coins
	zero_label.text = str(100)
	one_label.text = str(0)
