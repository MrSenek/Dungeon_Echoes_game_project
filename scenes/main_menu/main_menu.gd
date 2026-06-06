extends Node2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
var button_type:String
@onready var fade_timer: Timer = $fade_transition/fade_timer
@onready var fade_transition: ColorRect = $fade_transition
@onready var fade_animation: AnimationPlayer = $fade_transition/AnimationPlayer
@onready var new_continue_overlay: ColorRect = $New_Continue
@onready var new_continue_manager: Control = $new_continue_manager
@onready var continue_button: TextureButton = $new_continue_manager/continue
@onready var new_game_button: TextureButton = $new_continue_manager/new_game
@onready var audio_stream_player: AudioStreamPlayer = $button_hover
@onready var button_click: AudioStreamPlayer = $button_click
@onready var menu_music: AudioStreamPlayer = $"music menu"
@onready var music_slider: HSlider = $"button manager/audio_settings/MusicSlider"
@onready var sfx_slider: HSlider = $"button manager/audio_settings/SfxSlider"
@onready var music_value_label: Label = $"button manager/audio_settings/MusicValue"
@onready var sfx_value_label: Label = $"button manager/audio_settings/SfxValue"

const MENU_FONT: FontFile = preload("res://scenes/main_menu/Star Crush.ttf")



var choice_menu_open := false
var difficulty_panel: PanelContainer
var difficulty_buttons: Array[Button] = []
var difficulty_tween: Tween

func _ready() -> void:
	fade_transition.show()
	fade_animation.play("fade_out")
	new_continue_overlay.hide()
	new_continue_manager.hide()
	_create_difficulty_panel()
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
	_show_difficulty_panel()


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
	_hide_difficulty_panel()


func _create_difficulty_panel() -> void:
	difficulty_panel = PanelContainer.new()
	difficulty_panel.name = "DifficultyPanel"
	difficulty_panel.visible = false
	difficulty_panel.position = Vector2(570, 170)
	difficulty_panel.custom_minimum_size = Vector2(780, 485)
	difficulty_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	difficulty_panel.add_theme_stylebox_override("panel", _make_panel_style())
	new_continue_manager.add_child(difficulty_panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 38)
	margin.add_theme_constant_override("margin_top", 30)
	margin.add_theme_constant_override("margin_right", 38)
	margin.add_theme_constant_override("margin_bottom", 30)
	difficulty_panel.add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 14)
	margin.add_child(vbox)

	var title := Label.new()
	title.text = "CHOOSE DIFFICULTY"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_override("font", MENU_FONT)
	title.add_theme_font_size_override("font_size", 34)
	title.add_theme_color_override("font_color", Color(1.0, 0.88, 0.48, 1.0))
	title.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.9))
	title.add_theme_constant_override("shadow_offset_x", 3)
	title.add_theme_constant_override("shadow_offset_y", 3)
	vbox.add_child(title)

	var subtitle := Label.new()
	subtitle.text = "Pick how brutal the dungeon should be."
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.add_theme_font_override("font", MENU_FONT)
	subtitle.add_theme_font_size_override("font_size", 18)
	subtitle.add_theme_color_override("font_color", Color(0.82, 0.78, 0.68, 1.0))
	subtitle.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.8))
	subtitle.add_theme_constant_override("shadow_offset_x", 1)
	subtitle.add_theme_constant_override("shadow_offset_y", 1)
	vbox.add_child(subtitle)

	for difficulty in [DifficultySettings.EASY, DifficultySettings.NORMAL, DifficultySettings.HARD]:
		var button := Button.new()
		DifficultySettings.set_difficulty(difficulty)
		var accent := _get_difficulty_color(difficulty)
		button.text = "%s\n%s" % [DifficultySettings.get_display_name(), DifficultySettings.get_description()]
		button.custom_minimum_size = Vector2(704, 82)
		button.pivot_offset = button.custom_minimum_size * 0.5
		button.focus_mode = Control.FOCUS_CLICK
		button.clip_text = true
		button.set_meta("accent_color", accent)
		button.add_theme_font_override("font", MENU_FONT)
		button.add_theme_font_size_override("font_size", 21)
		button.add_theme_color_override("font_color", Color(0.96, 0.91, 0.78, 1.0))
		button.add_theme_color_override("font_hover_color", Color.WHITE)
		button.add_theme_color_override("font_pressed_color", Color(0.1, 0.06, 0.04, 1.0))
		_style_difficulty_button(button, accent)
		button.mouse_entered.connect(_on_difficulty_mouse_entered.bind(button))
		button.mouse_exited.connect(_on_difficulty_mouse_exited.bind(button))
		button.pressed.connect(_on_difficulty_pressed.bind(difficulty))
		difficulty_buttons.append(button)
		vbox.add_child(button)
	DifficultySettings.set_difficulty(PlayerData.difficulty)

	var back_button := Button.new()
	back_button.text = "BACK"
	back_button.custom_minimum_size = Vector2(704, 50)
	back_button.pivot_offset = back_button.custom_minimum_size * 0.5
	back_button.focus_mode = Control.FOCUS_CLICK
	back_button.add_theme_font_override("font", MENU_FONT)
	back_button.add_theme_font_size_override("font_size", 18)
	back_button.add_theme_color_override("font_color", Color(0.86, 0.82, 0.72, 1.0))
	back_button.add_theme_color_override("font_hover_color", Color.WHITE)
	back_button.set_meta("accent_color", Color(0.72, 0.68, 0.58, 1.0))
	_style_difficulty_button(back_button, Color(0.72, 0.68, 0.58, 1.0), true)
	back_button.mouse_entered.connect(_on_difficulty_mouse_entered.bind(back_button))
	back_button.mouse_exited.connect(_on_difficulty_mouse_exited.bind(back_button))
	back_button.pressed.connect(_hide_difficulty_panel)
	difficulty_buttons.append(back_button)
	vbox.add_child(back_button)


func _show_difficulty_panel() -> void:
	continue_button.hide()
	new_game_button.hide()
	if difficulty_tween:
		difficulty_tween.kill()
	difficulty_panel.modulate.a = 0.0
	difficulty_panel.scale = Vector2(0.94, 0.94)
	difficulty_panel.show()
	difficulty_tween = create_tween()
	difficulty_tween.set_parallel(true)
	difficulty_tween.tween_property(difficulty_panel, "modulate:a", 1.0, 0.18)
	difficulty_tween.tween_property(difficulty_panel, "scale", Vector2.ONE, 0.22).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _hide_difficulty_panel() -> void:
	if difficulty_panel:
		difficulty_panel.hide()
	continue_button.show()
	new_game_button.show()


func _on_difficulty_pressed(difficulty: String) -> void:
	button_click.play()
	PlayerData.difficulty = difficulty
	DifficultySettings.set_difficulty(difficulty)
	PlayerData.reset_data()
	button_type = "start"
	fade_timer.start()
	fade_transition.show()
	fade_animation.play("fade_in")


func _on_difficulty_mouse_entered(button: Button) -> void:
	audio_stream_player.play()
	var accent: Color = button.get_meta("accent_color", Color(1.0, 0.88, 0.48, 1.0))
	button.scale = Vector2(1.025, 1.025)
	button.modulate = Color(1.08, 1.04, 0.94, 1.0)
	button.add_theme_stylebox_override("normal", _make_button_style(Color(0.18, 0.105, 0.075, 0.98), accent, 3))


func _on_difficulty_mouse_exited(button: Button) -> void:
	var accent: Color = button.get_meta("accent_color", Color(1.0, 0.88, 0.48, 1.0))
	button.scale = Vector2.ONE
	button.modulate = Color.WHITE
	button.add_theme_stylebox_override("normal", _make_button_style(Color(0.085, 0.07, 0.065, 0.94), accent, 2))


func _make_panel_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.028, 0.023, 0.021, 0.96)
	style.border_color = Color(0.78, 0.46, 0.16, 0.95)
	style.border_width_left = 3
	style.border_width_top = 3
	style.border_width_right = 3
	style.border_width_bottom = 3
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	style.shadow_color = Color(0.0, 0.0, 0.0, 0.65)
	style.shadow_size = 18
	style.shadow_offset = Vector2(0, 8)
	return style


func _style_difficulty_button(button: Button, accent: Color, compact := false) -> void:
	button.add_theme_stylebox_override("normal", _make_button_style(Color(0.085, 0.07, 0.065, 0.94), accent, 2))
	button.add_theme_stylebox_override("hover", _make_button_style(Color(0.18, 0.105, 0.075, 0.98), accent, 3))
	button.add_theme_stylebox_override("pressed", _make_button_style(accent, Color(1.0, 0.9, 0.55, 1.0), 3))
	button.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	if compact:
		button.add_theme_constant_override("h_separation", 0)


func _make_button_style(bg_color: Color, border_color: Color, border_width: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = bg_color
	style.border_color = border_color
	style.border_width_left = border_width
	style.border_width_top = border_width
	style.border_width_right = border_width
	style.border_width_bottom = border_width
	style.corner_radius_top_left = 6
	style.corner_radius_top_right = 6
	style.corner_radius_bottom_left = 6
	style.corner_radius_bottom_right = 6
	style.shadow_color = Color(0.0, 0.0, 0.0, 0.35)
	style.shadow_size = 6
	style.shadow_offset = Vector2(0, 3)
	return style


func _get_difficulty_color(difficulty: String) -> Color:
	match difficulty:
		DifficultySettings.EASY:
			return Color(0.32, 0.95, 0.62, 1.0)
		DifficultySettings.NORMAL:
			return Color(1.0, 0.74, 0.26, 1.0)
		DifficultySettings.HARD:
			return Color(1.0, 0.26, 0.2, 1.0)
	return Color(1.0, 0.88, 0.48, 1.0)
