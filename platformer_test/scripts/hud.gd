extends CanvasLayer

@onready var coins_label: Label = $CoinsLabel
@onready var zero_label: Label = $Percent0
@onready var one_label: Label = $Percent1
@onready var heart_label: Label = $HeartLabel

func _ready() -> void:
	coins_label.text = str(0)
	zero_label.text = str(100.0)
	one_label.text = str(0.0)
	heart_label.text = str(3)
