extends TextEdit  # Control node is fine
@onready var label: Label = $Dialogue

var filepath = "res://scripts/objects/dialogue.json"
var parsedResult = {}

# --- Typewriter variables ---
var full_text: String = ""
var typing_speed: float = 0.03
var typing_timer: float = 0.0
var typing: bool = false

func _ready() -> void:
	load_json(filepath)

func load_json(path: String) -> void:
	if FileAccess.file_exists(path):
		var f = FileAccess.open(path, FileAccess.READ)
		parsedResult = JSON.parse_string(f.get_as_text())
	else:
		parsedResult = {}

# Called by NPC to start dialogue
func start_dialogue(dialogname: String, index: int = 0) -> void:
	if parsedResult.has(dialogname) and index < parsedResult[dialogname].size():
		full_text = parsedResult[dialogname][index][str(index)]
		label.text = full_text          # full text loaded at once
		label.visible_characters = 0    # typewriter starts hidden
		typing_timer = 0.0
		typing = true
	else:
		print("Dialogue not found:", dialogname, index)

func _process(delta: float) -> void:
	if typing:
		typing_timer += delta
		if typing_timer >= typing_speed:
			typing_timer = 0.0
			if label.visible_characters < full_text.length():
				label.visible_characters += 1
			else:
				typing = false  # finished typing

# Skip typewriter effect
func skip_or_finish() -> void:
	if typing:
		label.visible_characters = -1
		typing = false
