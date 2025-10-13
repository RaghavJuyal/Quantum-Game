extends CharacterBody2D
@onready var merlin: CharacterBody2D = $"." 
@onready var interact_area: Area2D = $interact_area
@onready var text_edit: RichTextLabel = $"../../Textcontainer/texts/TextEdit"
@onready var game_manager: Node = get_tree().root.get_node("Game/GameManager")

var interacting = false
var index = 0

const SPEED = 100.0
const JUMP_VELOCITY = -250.0

func _ready() -> void:
	interact_area.add_to_group("interact_merlin")

func _physics_process(delta: float) -> void:
	# Interaction key
	if interacting and Input.is_action_just_pressed("ui_accept"):
		if text_edit.typing:
			# Skip typewriter effect
			text_edit.skip_or_finish()
		else:
			# Advance to next line
			index += 1
			dialogue_sound()
			if index >= len(text_edit.parsedResult.get(self.name, [])):
				interacting = false
				text_edit.visible = false
				game_manager.Starter()
			else:
				text_edit.start_dialogue(self.name, index)

	# Gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	move_and_slide()

func dialogue_sound():
	var sound_player = get_node_or_null("DialogueLoad")
	if sound_player and not sound_player.playing:
		sound_player.play()

func handle_interaction():
	if interacting:
		return
	index = 0
	interacting = true
	text_edit.visible = true
	game_manager.Stopper()
	text_edit.start_dialogue(self.name, index)
	dialogue_sound()
