extends Node2D

@export var bullet_scene: PackedScene = preload("res://scenes/bullet.tscn")
@export var fire_rate: float = 0.75   # seconds between shots
@export var bullet_offset: Vector2 = Vector2(-10, 0)

var timer := 0.0

func _process(delta: float) -> void:
	timer += delta
	if timer >= fire_rate:
		fire_bullet()
		timer = 0.0

func fire_bullet():
	if bullet_scene:
		var bullet = bullet_scene.instantiate()
		bullet.global_position = global_position + bullet_offset
		get_tree().current_scene.add_child(bullet)
