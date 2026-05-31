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
@onready var menu_music: AudioStreamPlayer = $"music menu"
@onready var music_slider: HSlider = $"button manager/audio_settings/MusicSlider"
@onready var sfx_slider: HSlider = $"button manager/audio_settings/SfxSlider"
@onready var music_value_label: Label = $"button manager/audio_settings/MusicValue"
@onready var sfx_value_label: Label = $"button manager/audio_settings/SfxValue"



var choice_menu_open := false

func _ready() -> void:
	fade_transition.show()
	fade_animation.play("fade_out")
	new_continue_overlay.hide()
	new_continue_manager.hide()
	_assign_audio_buses()
	_setup_audio_settings()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("Pause") and choice_menu_open:
		_close_choice_menu()
		get_viewport().set_input_as_handled()


func _on_start_pressed() -> void:
	button_click.play()
	if choice_menu_open:
		return

	choice_menu_open = true
	new_continue_overlay.show()
	new_continue_manager.show()
	animation_player.play("button_start")
	animation_player.queue("New_continue_enter")

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
	elif button_type == "quit":
		get_tree().quit()




func _on_start_mouse_entered() -> void:
	audio_stream_player.play()


func _on_quit_mouse_entered() -> void:
	audio_stream_player.play()


func _on_continue_mouse_entered() -> void:
	audio_stream_player.play()


func _on_new_game_mouse_entered() -> void:
	audio_stream_player.play()


func _setup_audio_settings() -> void:
	music_slider.value_changed.connect(_on_music_slider_value_changed)
	sfx_slider.value_changed.connect(_on_sfx_slider_value_changed)
	sfx_slider.drag_ended.connect(_on_sfx_slider_drag_ended)

	music_slider.set_value_no_signal(AudioSettings.music_volume * 100.0)
	sfx_slider.set_value_no_signal(AudioSettings.sfx_volume * 100.0)
	_update_audio_value_labels()


func _assign_audio_buses() -> void:
	menu_music.bus = AudioSettings.MUSIC_BUS
	audio_stream_player.bus = AudioSettings.SFX_BUS
	button_click.bus = AudioSettings.SFX_BUS
	AudioSettings.apply_volumes()


func _on_music_slider_value_changed(value: float) -> void:
	AudioSettings.set_music_volume(value / 100.0)
	_update_audio_value_labels()


func _on_sfx_slider_value_changed(value: float) -> void:
	AudioSettings.set_sfx_volume(value / 100.0)
	_update_audio_value_labels()


func _on_sfx_slider_drag_ended(value_changed: bool) -> void:
	if value_changed:
		button_click.play()


func _update_audio_value_labels() -> void:
	music_value_label.text = "%d%%" % int(round(AudioSettings.music_volume * 100.0))
	sfx_value_label.text = "%d%%" % int(round(AudioSettings.sfx_volume * 100.0))


func _close_choice_menu() -> void:
	button_click.play()
	choice_menu_open = false
	animation_player.clear_queue()
	animation_player.play("RESET")
	new_continue_overlay.hide()
	new_continue_manager.hide()
