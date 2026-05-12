extends Node2D
@onready var fade_transition: ColorRect = $fade_transition
@onready var fade_animation: AnimationPlayer = $fade_transition/AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	fade_transition.show()
	fade_animation.play("fade_out")
