#in this animation, I first rotate left arrow to go down, then right arrow goes down as
#left arrow goes up to symbolize entanglement, then left arrow goes down again and
#finally, both arrows go up

extends Node3D
var angle = 0
var angle2 = 0
var delta_angle = 0.02
var eps = 1e-5
var rotating = true
var rotating2 = false
@onready var parent_arrow: Node3D = $Parent_arrow
@onready var parent_arrow_2: Node3D = $Parent_arrow2

func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	if rotating:
		angle += delta_angle
		parent_arrow.rotate(Vector3(1,0,0), delta_angle)
	if angle >= 3*PI:
		rotating2 = true
	if angle >= 2*PI:
		rotating = false
	elif angle >= PI:
		rotating2 = true
	
	if rotating2:
		angle2 += delta_angle
		parent_arrow_2.rotate(Vector3(1,0,0), delta_angle)
	
	if angle2 >= 2*PI:
		angle2 = 0
		angle = 0
		rotating2 = false
		rotating = true
	elif angle2 >= PI:
		rotating = true
		rotating2 = false
	
