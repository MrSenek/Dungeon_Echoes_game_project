extends Node2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
var button_type:String
@onready var fade_timer: Timer = $fade_transition/fade_timer
@onready var fade_transition: ColorRect = $fade_transition
@onready var fade_animation: AnimationPlayer = $fade_transition/AnimationPlayer

func _ready() -> void:
	fade_transition.show()
	fade_animation.play("fade_out")


func _on_start_pressed() -> void:
	button_type = "start"
	animation_player.play("button_start")
	fade_timer.start()
	fade_transition.show()
	fade_animation.play("fade_in")

func _on_test_arena_pressed() -> void:
	button_type = "test arena"
	animation_player.play("button_test_arena")
	fade_timer.start()
	fade_transition.show()
	fade_animation.play("fade_in")

func _on_quit_pressed() -> void:
	button_type = "quit"
	animation_player.play("button_quit")
	fade_timer.start()
	fade_transition.show()
	fade_animation.play("fade_in")



func _on_fade_timer_timeout() -> void:
	if button_type == "start":
		get_tree().change_scene_to_file("res://scenes/main_map/main_map.tscn")
	elif button_type == "test arena":
		get_tree().change_scene_to_file("res://scenes/test_map/mapa.tscn")
	elif button_type == "quit":
		get_tree().quit()
