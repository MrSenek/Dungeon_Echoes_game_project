extends Node2D
@onready var fade_transition: ColorRect = $fade_transition
@onready var fade_animation: AnimationPlayer = $fade_transition/AnimationPlayer
@onready var death_screen: CanvasLayer = $DeathScreen

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	fade_transition.show()
	fade_animation.play("fade_out")


func reset_scene():
	fade_transition.show()
	fade_animation.speed_scale = 4
	fade_animation.play("fade_in")
	await get_tree().create_timer(0.5).timeout
	get_tree().reload_current_scene()


func show_death_screen():
	death_screen.show_death_screen()
