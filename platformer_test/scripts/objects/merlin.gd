extends CharacterBody2D
@onready var merlin: CharacterBody2D = $"."
@onready var interact_area: Area2D = $interact_area
@onready var text_edit: TextEdit = $"../../Textcontainer/texts/TextEdit"
@onready var game_manager: Node = get_tree().root.get_node("Game/GameManager")

var interacting = false
var index = 0




const SPEED = 100.0
const JUMP_VELOCITY = -250.0

func _ready() -> void:
	interact_area.add_to_group("interact_merlin")

func _physics_process(delta: float) -> void:
	if interacting:
		if Input.is_action_just_pressed("ui_accept"):
			if text_edit.typing:
				# Skip typing and instantly show full line
				text_edit.label.text = text_edit.full_text
				text_edit.typing = false
			else:
				# Go to next line
				index += 1
				if len(text_edit.parsedResult[self.name]) <= index:
					interacting = false
					game_manager.Starter()
					text_edit.visible = false
				else:
					text_edit.dialogreader(self.name, index)

	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	

	move_and_slide()

func handle_interaction():
	index = 0
	interacting = true
	text_edit.visible = true
	game_manager.Stopper()
	text_edit.dialogreader(self.name, index)
