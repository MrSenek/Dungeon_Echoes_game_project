extends Node2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
var button_type:String
@onready var fade_timer: Timer = $fade_transition/fade_timer
@onready var fade_transition: ColorRect = $fade_transition
@onready var fade_animation: AnimationPlayer = $fade_transition/AnimationPlayer
@onready var new_continue_overlay: ColorRect = $New_Continue
@onready var new_continue_manager: Control = $new_continue_manager
@onready var audio_stream_player: AudioStreamPlayer = $button_hover
@onready var button_click: AudioStreamPlayer = $button_click



var choice_menu_open := false

func _ready() -> void:
	fade_transition.show()
	fade_animation.play("fade_out")
	new_continue_overlay.hide()
	new_continue_manager.hide()


func _on_start_pressed() -> void:
	button_click.play()
	if choice_menu_open:
		return

	choice_menu_open = true
	new_continue_overlay.show()
	new_continue_manager.show()
	animation_player.play("button_start")
	animation_player.queue("New_continue_enter")

func _on_test_arena_pressed() -> void:
	button_click.play()
	button_type = "test arena"
	animation_player.play("button_test_arena")
	fade_timer.start()
	fade_transition.show()
	fade_animation.play("fade_in")

func _on_quit_pressed() -> void:
	button_click.play()
	button_type = "quit"
	animation_player.play("button_quit")
	fade_timer.start()
	fade_transition.show()
	fade_animation.play("fade_in")


func _on_new_game_pressed() -> void:
	button_click.play()
	button_type = "start"
	PlayerData.reset_data()
	fade_timer.start()
	fade_transition.show()
	fade_animation.play("fade_in")


func _on_continue_pressed() -> void:
	button_click.play()
	button_type = "start"
	if not PlayerData.load_data():
		PlayerData.reset_data()
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




func _on_start_mouse_entered() -> void:
	audio_stream_player.play()


func _on_test_arena_mouse_entered() -> void:
	audio_stream_player.play()


func _on_quit_mouse_entered() -> void:
	audio_stream_player.play()


func _on_continue_mouse_entered() -> void:
	audio_stream_player.play()


func _on_new_game_mouse_entered() -> void:
	audio_stream_player.play()
