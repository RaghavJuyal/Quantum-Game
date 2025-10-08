extends CanvasLayer
@onready var label: Label = $Label
@onready var label_2: Label = $Label2
@onready var label_3: Label = $Label3

@onready var game_manager: Node = $".."
const selector_scene = "res://scenes/level_selector.tscn"
# Called when the node enters the scene tree for the first time.
const SUCCESS_MESSAGES = [
	"Unexpected outcome: competence",
	"I'd clap for you but I'm just a code.",
	"You passed. Our standards must be low.",
	"Against all odds… success.",
	"That actually worked!"
]
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_try_again_pressed() -> void:
	self.visible = false
	get_tree().paused = false
	label_3.visible = false
	game_manager.progress_reset()
	game_manager.load_level(game_manager.current_level_path)


func _on_level_select_pressed() -> void:
	self.visible = false
	get_tree().paused = false
	label_3.visible = false
	game_manager.progress_reset()
	game_manager.load_level(selector_scene)
