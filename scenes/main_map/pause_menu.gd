extends CanvasLayer


@onready var button_hover: AudioStreamPlayer = $button_hover
@onready var button_click: AudioStreamPlayer = $button_click
@onready var overlay: ColorRect = $ColorRect
@onready var menu_vbox: VBoxContainer = $"Control/MarginContainer/VBoxContainer"

var paused = false
var graphics_button: Button
var graphics_panel: PanelContainer
var graphics_preset_buttons: Array[Button] = []
var pause_blur_material: Material


func _ready() -> void:
	pause_blur_material = overlay.material
	_setup_graphics_menu()
	_apply_pause_blur_setting()
	var graphics_settings = _get_graphics_settings()
	if graphics_settings:
		graphics_settings.connect("settings_changed", Callable(self, "_on_graphics_settings_changed"))


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("Pause"):
		pauseMenu()


func pauseMenu():
	if !paused:
		show()
		get_tree().paused = true
	else:
		hide()
		get_tree().paused = false
	paused = !paused


func _on_resume_pressed() -> void:
	button_click.play()
	pauseMenu()



func _on_exitsave_pressed() -> void:
	button_click.play()
	await get_tree().create_timer(0.5, true, false, true).timeout
	PlayerData.save_game()
	
	get_tree().quit()


func _on_resume_mouse_entered() -> void:
	button_hover.play()


func _on_exitsave_mouse_entered() -> void:
	button_hover.play()


func _setup_graphics_menu() -> void:
	graphics_button = Button.new()
	graphics_button.custom_minimum_size = Vector2(330, 48)
	graphics_button.focus_mode = Control.FOCUS_CLICK
	graphics_button.pressed.connect(_toggle_graphics_panel)
	graphics_button.mouse_entered.connect(_on_graphics_button_mouse_entered)
	_style_pause_button(graphics_button)
	menu_vbox.add_child(graphics_button)

	graphics_panel = PanelContainer.new()
	graphics_panel.name = "GraphicsPanel"
	graphics_panel.visible = false
	graphics_panel.position = Vector2(96, 220)
	graphics_panel.custom_minimum_size = Vector2(470, 440)
	graphics_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	graphics_panel.add_theme_stylebox_override("panel", _make_panel_style())
	$Control.add_child(graphics_panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 24)
	margin.add_theme_constant_override("margin_top", 22)
	margin.add_theme_constant_override("margin_right", 24)
	margin.add_theme_constant_override("margin_bottom", 22)
	graphics_panel.add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	margin.add_child(vbox)

	var title := Label.new()
	title.text = "GRAPHICS"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 28)
	title.add_theme_color_override("font_color", Color(1.0, 0.86, 0.5, 1.0))
	vbox.add_child(title)

	var graphics_settings = _get_graphics_settings()
	if graphics_settings == null:
		return

	for preset in graphics_settings.get_preset_order():
		var preset_button := Button.new()
		preset_button.custom_minimum_size = Vector2(420, 68)
		preset_button.focus_mode = Control.FOCUS_CLICK
		preset_button.clip_text = true
		preset_button.pressed.connect(_on_graphics_preset_pressed.bind(preset))
		preset_button.mouse_entered.connect(_on_graphics_button_mouse_entered)
		_style_pause_button(preset_button)
		graphics_preset_buttons.append(preset_button)
		vbox.add_child(preset_button)

	_update_graphics_labels()


func _toggle_graphics_panel() -> void:
	button_click.play()
	graphics_panel.visible = not graphics_panel.visible


func _on_graphics_preset_pressed(preset: String) -> void:
	button_click.play()
	var graphics_settings = _get_graphics_settings()
	if graphics_settings:
		graphics_settings.set_preset(preset)


func _on_graphics_settings_changed() -> void:
	_update_graphics_labels()
	_apply_pause_blur_setting()


func _update_graphics_labels() -> void:
	var graphics_settings = _get_graphics_settings()
	if graphics_settings == null:
		return

	if graphics_button:
		graphics_button.text = "GRAPHICS: %s" % graphics_settings.get_preset_label()

	var preset_order: Array = graphics_settings.get_preset_order()
	for i in range(graphics_preset_buttons.size()):
		var preset: String = preset_order[i]
		var button := graphics_preset_buttons[i]
		var marker := "> " if preset == graphics_settings.preset else "  "
		button.text = "%s%s\n%s" % [
			marker,
			graphics_settings.get_preset_label(preset),
			graphics_settings.get_preset_description(preset),
		]


func _apply_pause_blur_setting() -> void:
	var graphics_settings = _get_graphics_settings()
	if graphics_settings == null:
		return
	overlay.color = Color(0.0, 0.0, 0.0, 0.45)
	overlay.material = pause_blur_material if graphics_settings.should_use_pause_blur() else null


func _get_graphics_settings():
	return get_node_or_null("/root/GraphicsSettings")


func _on_graphics_button_mouse_entered() -> void:
	button_hover.play()


func _style_pause_button(button: Button) -> void:
	button.add_theme_stylebox_override("normal", _make_button_style(Color(0.08, 0.07, 0.065, 0.94), Color(0.68, 0.43, 0.18, 1.0), 2))
	button.add_theme_stylebox_override("hover", _make_button_style(Color(0.16, 0.105, 0.075, 0.98), Color(1.0, 0.74, 0.28, 1.0), 3))
	button.add_theme_stylebox_override("pressed", _make_button_style(Color(0.9, 0.62, 0.24, 1.0), Color(1.0, 0.9, 0.55, 1.0), 3))
	button.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	button.add_theme_color_override("font_color", Color(0.94, 0.88, 0.72, 1.0))
	button.add_theme_color_override("font_hover_color", Color.WHITE)
	button.add_theme_font_size_override("font_size", 18)


func _make_panel_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.03, 0.025, 0.022, 0.96)
	style.border_color = Color(0.78, 0.46, 0.16, 0.95)
	style.border_width_left = 3
	style.border_width_top = 3
	style.border_width_right = 3
	style.border_width_bottom = 3
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	style.shadow_color = Color(0.0, 0.0, 0.0, 0.62)
	style.shadow_size = 16
	style.shadow_offset = Vector2(0, 8)
	return style


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
	style.shadow_size = 5
	style.shadow_offset = Vector2(0, 2)
	return style
