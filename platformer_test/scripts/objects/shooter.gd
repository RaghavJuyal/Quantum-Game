extends CharacterBody2D

@export var bullet_scene: PackedScene = preload("res://scenes/objects/bullet.tscn")
@export var fire_rate: float = 0.5   # seconds between shots
@export var bullet_offset: Vector2 = Vector2(10, 0)
@export var direction := 1  # 1 = right, -1 = left
var stop = false

var timer := 0.0

func _ready():
	$AnimatedSprite2D.flip_h = (direction == -1)

func _process(delta: float) -> void:
	if !stop:
		timer += delta
		if timer >= fire_rate:
			fire_bullet()
			timer = 0.0

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	move_and_slide()

func fire_bullet():
	if bullet_scene:
		var bullet = bullet_scene.instantiate()
		bullet.global_position = direction*bullet_offset
		bullet.direction = direction
		self.add_child(bullet)
