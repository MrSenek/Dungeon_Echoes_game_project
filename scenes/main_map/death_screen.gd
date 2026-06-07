extends CanvasLayer

@onready var root: Control = $Root
@onready var dim: ColorRect = $Root/Dim
@onready var panel: PanelContainer = $Root/Panel
@onready var vbox: VBoxContainer = $Root/Panel/MarginContainer/VBoxContainer
@onready var summary: Label = $Root/Panel/MarginContainer/VBoxContainer/Summary
@onready var restart_button: Button = $Root/Panel/MarginContainer/VBoxContainer/ButtonRow/RestartButton
@onready var quit_button: Button = $Root/Panel/MarginContainer/VBoxContainer/ButtonRow/QuitButton

var show_tween: Tween
var selected_button: Button
var stats_label: Label

func _ready() -> void:
	hide()
	root.modulate.a = 0.0
	panel.custom_minimum_size = Vector2(580, 430)
	_create_stats_label()
	_setup_button_selection(restart_button)
	_setup_button_selection(quit_button)


func show_death_screen() -> void:
	if is_instance_valid(show_tween):
		show_tween.kill()

	show()
	get_tree().paused = true
	Engine.time_scale = 0
	restart_button.disabled = true
	quit_button.disabled = true
	_update_stats_text()

	root.modulate.a = 1.0
	dim.modulate.a = 0.0
	panel.modulate.a = 0.0
	panel.scale = Vector2(0.9, 0.9)
	panel.pivot_offset = panel.size * 0.5

	show_tween = create_tween()
	show_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	show_tween.set_ignore_time_scale(true)
	show_tween.set_parallel(true)
	show_tween.tween_property(dim, "modulate:a", 1.0, 0.28)
	show_tween.tween_property(panel, "modulate:a", 1.0, 0.24).set_delay(0.08)
	show_tween.tween_property(panel, "scale", Vector2.ONE, 0.28).set_delay(0.08).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	show_tween.set_parallel(false)
	show_tween.tween_callback(Callable(self, "_finish_show"))


func _finish_show() -> void:
	restart_button.disabled = false
	quit_button.disabled = false
	_select_button(null)


func _on_restart_button_pressed() -> void:
	get_tree().paused = false
	Engine.time_scale = 1
	hide()
	get_tree().current_scene.reset_scene()


func _on_quit_button_pressed() -> void:
	get_tree().paused = false
	Engine.time_scale = 1
	PlayerData.save_game()
	get_tree().quit()


func _setup_button_selection(button: Button) -> void:
	button.focus_mode = Control.FOCUS_CLICK
	button.mouse_entered.connect(_select_button.bind(button))
	button.mouse_exited.connect(_clear_button_if_selected.bind(button))
	button.pivot_offset = button.size * 0.5


func _select_button(button: Button = null) -> void:
	if selected_button and selected_button != button:
		_set_button_selected(selected_button, false)

	selected_button = button
	if not selected_button:
		restart_button.release_focus()
		quit_button.release_focus()
		return

	selected_button.grab_focus()
	_set_button_selected(selected_button, true)


func _clear_button_if_selected(button: Button) -> void:
	if selected_button != button:
		return

	_set_button_selected(button, false)
	selected_button = null
	button.release_focus()


func _set_button_selected(button: Button, selected: bool) -> void:
	if selected:
		button.scale = Vector2(1.04, 1.04)
		button.modulate = Color(1.16, 1.06, 0.88, 1.0)
	else:
		button.scale = Vector2.ONE
		button.modulate = Color.WHITE


func _create_stats_label() -> void:
	stats_label = Label.new()
	stats_label.name = "RunStats"
	stats_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	stats_label.add_theme_font_size_override("font_size", 17)
	stats_label.add_theme_color_override("font_color", Color(0.96, 0.9, 0.78, 1))
	stats_label.add_theme_color_override("font_shadow_color", Color(0.02, 0.01, 0.0, 0.85))
	stats_label.add_theme_constant_override("shadow_offset_x", 1)
	stats_label.add_theme_constant_override("shadow_offset_y", 1)
	stats_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

	var button_row := $Root/Panel/MarginContainer/VBoxContainer/ButtonRow
	vbox.add_child(stats_label)
	vbox.move_child(stats_label, button_row.get_index())


func _update_stats_text() -> void:
	summary.text = "The expedition has ended. Your best run details:"
	stats_label.text = "Score: %d\nBest score: %d\nDifficulty: %s\nWaves cleared: %d\nEnemies defeated: %d\nCoins collected: %d\nBest combo: x%d" % [
		PlayerData.run_score,
		PlayerData.best_score,
		DifficultySettings.get_display_name(),
		PlayerData.run_waves_cleared,
		PlayerData.run_enemies_killed,
		PlayerData.run_coins_collected,
		PlayerData.run_best_combo
	]
